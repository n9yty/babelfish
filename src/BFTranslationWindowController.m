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

#import "BFTranslationWindowController.h"
#import "BFGoogleTranslator.h"
#import "BFTranslateTextOperation.h"
#import "BFLanguage.h"
#import "BFTranslationWindowModel.h"

@implementation BFTranslationWindowController

@synthesize model;

static NSString const* BFOriginalTextChangedCtxKey = @"BFOriginalTextChangedCtxKey";
static NSString const* BFTranslationChangedCtxKey = @"BFTranslationChangedCtxKey";
static NSString const* BFSourceLanguageChangedCtxKey = @"BFSourceLanguageChangedCtxKey";
static NSString const* BFTargetLanguageChangedCtxKey = @"BFTargetLanguageChangedCtxKey";

static NSTimeInterval const BFDelayBetweenTranslations = 1.0;
static NSInteger const BFMaxTextSizeForInteractiveTranslation = 1024;

- (id)initWithModel:(BFTranslationWindowModel*)aModel {	
	if (![super initWithWindowNibName:@"TranslationWindow"]) {
		return nil;
	}
		
	model = [aModel retain];	
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(translationOperationDidFinish:) name:BFTranslationFinishedNotificationKey object:nil];
	
	[model addObserver:self forKeyPath:@"originalText" options:NSKeyValueObservingOptionNew context:&BFOriginalTextChangedCtxKey];
	[model addObserver:self forKeyPath:@"translation" options:NSKeyValueObservingOptionNew context:&BFTranslationChangedCtxKey];
	[model addObserver:self forKeyPath:@"selectedSourceLanguage" options:NSKeyValueObservingOptionNew context:&BFSourceLanguageChangedCtxKey];
	[model addObserver:self forKeyPath:@"selectedTargetLanguage" options:NSKeyValueObservingOptionNew context:&BFTargetLanguageChangedCtxKey];
		
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[operationQueue cancelAllOperations];
	[operationQueue release];	
	
	[model release];
	[translateTimer release];
	[requestedTextToTranslate release];
	[lastTextToTranslate release];
		
	[super dealloc];
}


- (void)awakeFromNib {
	// we start with no translation
	[self setTranslationBoxHidden:YES];
	
	// source languages
	[self populateMenu:[sourceLanguagePopup menu] withItems:[model sourceLanguages]];
		
	// target langages
	[self populateMenu:[targetLanguagePopup menu] withItems:[model targetLanguages]];
	
	// synchronize source language - FIXME issue#2
	if ([model selectedSourceLanguage]) {
		[sourceLanguagePopup selectItemWithTag:[[model selectedSourceLanguage] hash]];
	} else {
		[model setSelectedSourceLanguage:[[sourceLanguagePopup selectedItem] representedObject]];
	}
	
	// synchronize target language - FIXME issue#2
	if ([model selectedTargetLanguage]) {
		[targetLanguagePopup selectItemWithTag:[[model selectedTargetLanguage] hash]];
	} else {
		[model setSelectedTargetLanguage:[[targetLanguagePopup selectedItem] representedObject]];
	}
	
	[self handleOriginalTextChanged];
	[self handleLanguageSelectionChanged];
	[self handleTranslationChanged];
}

- (void) stopTranslateTimer {
	BFDevLog(@"Stopping timer");

	[translateTimer invalidate];
	[translateTimer release];
	translateTimer = nil;
}

- (void) startTranslateTimer {
	BFDevLog(@"Starting timer %@", translateTimer);
	
	if (!translateTimer) {
		translateTimer = [[NSTimer scheduledTimerWithTimeInterval:BFDelayBetweenTranslations target:self selector:@selector(translateTimerDidFire:) userInfo:nil repeats:YES] retain];
	}
}

- (void) translateTimerDidFire:(NSTimer *)aTimer {	
	BFDevLog(@"Time fired last: %@ new: %@", lastTextToTranslate, requestedTextToTranslate);
	
	if ([lastTextToTranslate isEqualToString:[requestedTextToTranslate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]) { 
		BFDevLog(@"text is the same - stopping");
		
		[self stopTranslateTimer];
	} else {				
		[self translate];
		
		[lastTextToTranslate release];
		lastTextToTranslate = [[requestedTextToTranslate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] retain];
	}
}

- (void) handleOriginalTextChanged {
	BFDevLog(@"Text changed %@", [model originalText]);
	
	NSInteger size = [[model originalText] length];
	
	if (size > 0) {
		[translateButton setEnabled:YES];
		
		if (size < BFMaxTextSizeForInteractiveTranslation) {
			// implicit translate
			BFDevLog(@"Implicit translation");
			
			[requestedTextToTranslate release];
			requestedTextToTranslate = [[model originalText] copy];
			
			if (!translateTimer) {
				BFDevLog(@"Timer not running - launching a new one");
				[self startTranslateTimer];
			}
		} else {
			// from now on we only use expricit translate
			BFDevLog(@"Explicit translation");
			
			if (translateTimer) {
				[self stopTranslateTimer];
			}
		}
	} else {
		[translateButton setEnabled:NO];
		[model setTranslation:@""];
		[self stopTranslateTimer];
	}
}

- (void) handleLanguageSelectionChanged {
	[swapLanguagesButton setHidden:[model selectedSourceLanguage] == [[model translator] autoDetectTargetLanguage]];
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
		if (e == nil) {
			[menu addItem: [NSMenuItem separatorItem]];
		} else if ([e isKindOfClass: [BFLanguage class]]) {
			BFLanguage *l = (BFLanguage *)e;
			NSMenuItem *mi = [menu addItemWithTitle:[l name] action:nil keyEquivalent:@""];
			[mi setRepresentedObject:l];
			[mi setImage:[l image]];
			[mi setTag:[l hash]];
		} else {
			BFFail(@"Unexpected item: %@", e);
		}
	}
}

- (void)translate {
	NSString* text = [model originalText];
	BFLanguage *from = [model selectedSourceLanguage];
	BFLanguage *to = [model selectedTargetLanguage];
	NSObject<BFTranslator> *translator = [model translator];
	
	// TODO assert	
	BFDevLog(@"translateText:\"%@\" from:\"%@\" to:\"%@\"", text, from, to);
	
	if ([lastTextToTranslate isEqualToString:[text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]]
		&& [[operationQueue operations] count] == 0) {
		
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Translate"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert setMessageText:@"Translate again?"];
		[alert setInformativeText:@"The same text has been already translated. Are you sure you wanna do it again?"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		
		if ([alert runModal] == NSAlertSecondButtonReturn) {
			// cancel clicked
			return;
		}
	}
	
	// cancel all pending translation (should be at max one)
	[operationQueue cancelAllOperations];
	
	// show busy animation
	[progressIndicator startAnimation:nil];
	
	// create a new translation operation
	BFTranslateTextOperation *operation = [[BFTranslateTextOperation alloc] initWithText:text from:from to:to translator:translator];
	
	// enqueue
	[operationQueue addOperation:operation];	
}

- (void)translationOperationDidFinish:(id)aNotification {
	BFDevLog(@"translationOperationDidFinish: %@", aNotification);
	
	[progressIndicator stopAnimation:nil];
	
	BFTranslateTextOperation *operation = [aNotification object];
	// TODO: assert operation != nil
	if ([operation error]) {
		// TODO: to retry count?
		
		[NSApp presentError:[operation error]];
		return;
	}
	
	[model setTranslation:[operation translation]];
	
	if (![[[model translator] autoDetectTargetLanguage] isEqual:[operation from]]) {
		[model setLastUsedSourceLanguage:[operation from]];
	}
	
	[model setLastUsedTargetLanguage:[operation to]];
	[self setTranslationBoxHidden:NO];
}


- (void)setTranslationBoxHidden:(BOOL)hidden {
	BFDevLog(@"setTranslationVisible: %d", hidden);
	
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
	[model setSelectedSourceLanguage:[[sourceLanguagePopup selectedItem] representedObject]];
}

- (IBAction)setTargetLanguage:(id)aSender {
	[model setSelectedTargetLanguage:[[targetLanguagePopup selectedItem] representedObject]];
}

- (IBAction)translateTextAction:(id)aSender {
	if (translateTimer) {
		[self stopTranslateTimer];
	}
	
	[self translate];
}

- (IBAction)copyTranslationAndCloseAction:(id)aSender {
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
	
	BFLanguage *s = [[sourceLanguagePopup selectedItem] representedObject];
	if (s == [[model translator] autoDetectTargetLanguage]) {
		return;
	}
	
	BFLanguage *t = [[targetLanguagePopup selectedItem] representedObject];
	
	[sourceLanguagePopup selectItemWithTag:[t hash]];
	[self setSourceLanguage:sourceLanguagePopup];
	[targetLanguagePopup selectItemWithTag:[s hash]];
	[self setTargetLanguage:targetLanguagePopup];
}

@end