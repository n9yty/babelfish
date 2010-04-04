/*
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
 COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING 
 IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
 OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//  Created by Filip Krikava on 11/26/09.

#import "TranslationWindowController.h"
#import "GoogleTranslator.h"
#import "TranslateTextOperation.h"
#import "LanguageManager.h"
#import "RatedLanguage.h"
#import "Translation.h"
#import "BFTranslationWindowModel.h"

@implementation TranslationWindowController

@synthesize model;

static NSString const* BFOriginalTextChangedCtxKey = @"BFOriginalTextChangedCtxKey";
static NSString const* BFTranslationChangedCtxKey = @"BFTranslationChangedCtxKey";
static NSString const* BFSourceLanguageChangedCtxKey = @"BFSourceLanguageChangedCtxKey";
static NSString const* BFTargetLanguageChangedCtxKey = @"BFTargetLanguageChangedCtxKey";

static NSTimeInterval const BFTypingStoppedDelay = 1.3;

static RatedLanguage const* BFAutoDetectedLanguage;

- (id)initWithModel:(BFTranslationWindowModel*)aModel {
#ifndef NDEBUG
	NSLog(@"Initializing %@", [TranslationWindowController class]);
#endif
	
	if (![super initWithWindowNibName:@"TranslationWindow"]) {
		return nil;
	}
	BFAutoDetectedLanguage = [RatedLanguage ratedLanguage:[[Language alloc] initWithCode:@"" name:@"Detect Language" imagePath:nil] tag:-1 rating:0];
	
	model = [aModel retain];	
	operationQueue = [[NSOperationQueue alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(translationOperationDidFinish:) name:BFTranslationFinishedNotificationKey object:nil];
	
	[model addObserver:self forKeyPath:@"originalText" options:NSKeyValueObservingOptionNew context:&BFOriginalTextChangedCtxKey];
	[model addObserver:self forKeyPath:@"translation" options:NSKeyValueObservingOptionNew context:&BFTranslationChangedCtxKey];
	[model addObserver:self forKeyPath:@"selectedSourceLanguage" options:NSKeyValueObservingOptionNew context:&BFSourceLanguageChangedCtxKey];
	[model addObserver:self forKeyPath:@"selectedTargetLanguage" options:NSKeyValueObservingOptionNew context:&BFTargetLanguageChangedCtxKey];
	
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [TranslationWindowController class]);
#endif
	
	//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[typingTimer release];
	[lastKeypress release];
	[lastOriginalText release];
	
	[operationQueue cancelAllOperations];
	[operationQueue release];	
	[model release];
	
	[BFAutoDetectedLanguage release];
	//	[selectLangMenuItem release];
	
	[super dealloc];
}

- (void)awakeFromNib {
#ifndef NDEBUG
	NSLog(@"TranslationWindow Nib has been loaded");
#endif
	
	[self setTranslationBoxHidden:YES];
	
	NSSortDescriptor *ratingSort = [[[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO] autorelease];
	NSSortDescriptor *nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	
	NSArray* langs = [[[model sourceLanguages] sortedArrayUsingDescriptors:[NSArray arrayWithObjects: ratingSort,nameSort,nil]] retain];
	
	// populate source language selector
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:BFAutoDetectedLanguage];
	[a addObject:[NSMenuItem separatorItem]];
	[a addObjectsFromArray:langs];
	
	[sourceLanguagePopup removeAllItems];
	[self populateMenu:[sourceLanguagePopup menu] withItems:a];
	
	// populate target language selector
	langs = [[[model targetLanguages] sortedArrayUsingDescriptors:[NSArray arrayWithObjects: ratingSort,nameSort,nil]] retain];
	
	[a removeAllObjects];
	[a addObjectsFromArray:langs];
	
	[targetLanguagePopup removeAllItems];
	[self populateMenu:[targetLanguagePopup menu] withItems:a];
	
	// synchronize source language - FIXME issue#2
	if ([model selectedSourceLanguage]) {
		[sourceLanguagePopup selectItemWithTag:[[model selectedSourceLanguage] tag]];
	} else {
		[model setSelectedSourceLanguage:[[sourceLanguagePopup selectedItem] representedObject]];
	}
	
	// synchronize target language - FIXME issue#2
	if ([model selectedTargetLanguage]) {
		[targetLanguagePopup selectItemWithTag:[[model selectedTargetLanguage] tag]];
	} else {
		[model setSelectedTargetLanguage:[[targetLanguagePopup selectedItem] representedObject]];
	}
	
	[self handleOriginalTextChanged];
	[self handleLanguageSelectionChanged];
	[self handleTranslationChanged];
}

- (void) stopTypingTimer {
	NSLog(@"Stopping timer");
	[typingTimer invalidate];
	[typingTimer release];
	typingTimer = nil;
}

- (void) startTypingTimer {
	NSLog(@"Starting timer %@", typingTimer);
	[self stopTypingTimer];
	if (!typingTimer) {
		lastKeypress = [[NSDate date] retain];
		typingTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(typingTimerDidFired:) userInfo:nil repeats:YES] retain];
	}
}

- (void) typingTimerDidFired:(NSTimer *)aTimer {
	NSDate *now = [NSDate date];
	NSTimeInterval interval = [now timeIntervalSinceDate:lastKeypress];
	NSString *originalText = [[[model originalText] copy] autorelease];
	
	NSLog(@"Time fired %f last: %@ new: %@", interval, lastOriginalText, originalText);
	
	if (interval > BFTypingStoppedDelay) {
		NSLog(@"Interval bigger than delay - stopping", interval);
		[self stopTypingTimer];
	} 	

	if ([lastOriginalText isEqualToString:originalText]) { 
		NSLog(@"text is the same");
	} else {		
		[lastKeypress release];
		lastKeypress = [now retain];
		
		[self translate];
	}

	// get the text
	[lastOriginalText release];
	lastOriginalText = [originalText retain];
}

- (void) handleOriginalTextChanged {
	NSLog(@"Text changed %@", [model originalText]);
	
	if ([[model originalText] length] > 0) {
		[translateButton setEnabled:YES];
		if (!typingTimer) {
			NSLog(@"Timer not running - launching a new one");
			[self startTypingTimer];
			[self translate];
		}
	} else {
		[translateButton setEnabled:NO];
		[model setTranslation:@""];
		[self stopTypingTimer];
	}
	
}

- (void) handleLanguageSelectionChanged {
	[swapLanguagesButton setHidden:[model selectedSourceLanguage] == BFAutoDetectedLanguage];
	if ([[model originalText] length] > 0) {
		[self translate];
	}
}

- (void) handleTranslationChanged {
	[copyAndCloseButton setEnabled:[[model translation] length] > 0];		
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &BFOriginalTextChangedCtxKey) {
		[self handleOriginalTextChanged];
	} else if (context == &BFSourceLanguageChangedCtxKey
			   || context == &BFTargetLanguageChangedCtxKey) {
		[self handleLanguageSelectionChanged];
	} else if (context == &BFTranslationChangedCtxKey) {
		[self handleTranslationChanged];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void) populateMenu:(NSMenu *)menu withItems:(NSArray *)items {
	for (id e in items) {
		if ([e isKindOfClass: [NSMenuItem class]]) {
			[menu addItem: (NSMenuItem *)e];
		} else if ([e isKindOfClass: [RatedLanguage class]]) {
			RatedLanguage *l = (RatedLanguage *)e;
			NSMenuItem *mi = [menu addItemWithTitle:[l name] action:nil keyEquivalent:@""];
			[mi setRepresentedObject:l];
			[mi setImage:[l image]];
			[mi setTag:[l tag]];
		} else {
			// TODO: crash here
			NSLog(@"Unexpected item: %@", e);
		}
	}
}

- (void)translate {
	NSString* text = [model originalText];
	Language *from = [model selectedSourceLanguage];
	Language *to = [model selectedTargetLanguage];
	NSObject<Translator> *translator = [model translator];
	
	// TODO assert
	
#ifndef NDEBUG
	NSLog(@"translateText:\"%@\" from:\"%@\" to:\"%@\"", text, from, to);
#endif
	
	// cancel all pending translation (should be at max one)
	[operationQueue cancelAllOperations];
	
	// show busy animation
	[progressIndicator startAnimation:nil];
	
	// create a new translation operation
	TranslateTextOperation *operation = [[TranslateTextOperation alloc] initWithText:text from:from to:to translator:translator];
	
	// enqueue
	[operationQueue addOperation:operation];	
}

- (void)translationOperationDidFinish:(id)aNotification {
#ifndef NDEBUG
	NSLog(@"translationOperationDidFinish: %@", aNotification);
#endif
	
	[progressIndicator stopAnimation:nil];
	
	TranslateTextOperation *operation = [aNotification object];
	// TODO: assert operation != nil
	if ([operation error]) {
		// TODO: to retry count?
		
		[NSApp presentError:[operation error]];
		return;
	}
	
	[model setTranslation:[operation translation]];
	[self setTranslationBoxHidden:NO];
}


- (void)setTranslationBoxHidden:(BOOL)hidden {
#ifndef NDEBUG
	NSLog(@"setTranslationVisible: %d", hidden);
#endif
	
	if ([translationBox isHidden] == hidden) {
		return; 
	}
	
	// hide translation view
	NSWindow* window = [translationBox window];
	NSRect frame = [window frame];
	
	// origin here has 0 at the bottom of the screen
	frame.origin.y += hidden ? [translationBox frame].size.height : -[translationBox frame].size.height;
	frame.size.height += hidden ? -[translationBox frame].size.height : [translationBox frame].size.height;
	
	if (hidden) {
		// first hide
		[translationBox setHidden:hidden];
		// then shortern
		[window setFrame:frame display:YES animate:YES];
	} else {
		// first extend the size
		[window setFrame:frame display:YES animate:YES];
		// then show
		[translationBox setHidden:hidden];
	}
	
}

- (IBAction)setSourceLanguage:(id)aSender {
#ifndef NDEBUG
	NSLog(@"setSourceLanguage:\"%@\"", aSender);	
#endif
	
	[model setSelectedSourceLanguage:[[sourceLanguagePopup selectedItem] representedObject]];
}

- (IBAction)setTargetLanguage:(id)aSender {
#ifndef NDEBUG
	NSLog(@"setTargetLanguage:\"%@\"", aSender);
#endif
	
	[model setSelectedTargetLanguage:[[targetLanguagePopup selectedItem] representedObject]];
}

- (IBAction)translateTextAction:(id)aSender {
	[self translate];
}

- (IBAction)copyTranslationAndCloseAction:(id)aSender {
#ifndef NDEBUG
	NSLog(@"copyTranslationAndCloseAction:\"%@\"", aSender);
#endif
	
	// TODO: this should be synchronized	
	NSString *string = [[model translation] copy];
	if (string == nil) {
		return;
	}
	
	// copy to pasteboard
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pboard setString:string forType:NSStringPboardType];
	
	[string release];
	
	// hide window
	[self close];
}

- (IBAction)swapLanguages:(id)aSender {
	RatedLanguage *s = [[sourceLanguagePopup selectedItem] representedObject];
	if (s == BFAutoDetectedLanguage) {
		return;
	}
	
	RatedLanguage *t = [[targetLanguagePopup selectedItem] representedObject];
	
	[sourceLanguagePopup selectItemWithTag:[t tag]];
	[self setSourceLanguage:sourceLanguagePopup];
	[targetLanguagePopup selectItemWithTag:[s tag]];
	[self setTargetLanguage:targetLanguagePopup];
}

@end