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

static NSString* cOriginalTextChangedCtx = @"cOriginalTextChangedCtx";
static NSString* cSourceLanguageChangedCtx = @"cSourceLanguageChangedCtx";
static NSString* cTargetLanguageChangedCtx = @"cTargetLanguageChangedCtx";

const RatedLanguage *autoDetectedLanguage;

- (id)initWithModel:(BFTranslationWindowModel*)aModel {
#ifndef NDEBUG
	NSLog(@"Initializing %@", [TranslationWindowController class]);
#endif
	
	if (![super initWithWindowNibName:@"TranslationWindow"]) {
		return nil;
	}
	
	model = [aModel retain];
	
	operationQueue = [[NSOperationQueue alloc] init];
	
	autoDetectedLanguage = [RatedLanguage ratedLanguage:[[Language alloc] initWithCode:@"auto" name:@"Auto-Detect" imagePath:nil] tag:-1 rating:0];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(translationOperationDidFinish:) name:BFTranslationFinishedNotificationKey object:nil];
	
	[model addObserver:self forKeyPath:@"originalText" options:NSKeyValueObservingOptionNew context:&cOriginalTextChangedCtx];
	[model addObserver:self forKeyPath:@"selectedSourceLanguage" options:NSKeyValueObservingOptionNew context:&cSourceLanguageChangedCtx];
	[model addObserver:self forKeyPath:@"selectedTargetLanguage" options:NSKeyValueObservingOptionNew context:&cTargetLanguageChangedCtx];
	
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [TranslationWindowController class]);
#endif
	
	//	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[operationQueue cancelAllOperations];
	[operationQueue release];	
	[model release];
	
	[autoDetectedLanguage release];
	//	[selectLangMenuItem release];
	
	[super dealloc];
}

- (void)awakeFromNib {
#ifndef NDEBUG
	NSLog(@"TranslationWindow Nib has been loaded");
#endif
	
	// hide translation view
	[translatedTextViewDisclosureTriangle setState:NSOffState];
	[self showHideTranslationViewAction:translatedTextViewDisclosureTriangle];
	
	NSSortDescriptor *ratingSort = [[[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO] autorelease];
	NSSortDescriptor *nameSort = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	
	NSArray* langs = [[[model sourceLanguages] sortedArrayUsingDescriptors:[NSArray arrayWithObjects: ratingSort,nameSort,nil]] retain];
	
	// populate source language selector
	NSMutableArray *a = [NSMutableArray array];
	[a addObject:autoDetectedLanguage];
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
	
	[self update];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &cOriginalTextChangedCtx
		|| context == &cSourceLanguageChangedCtx
		|| context == &cTargetLanguageChangedCtx) {
		[self update];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void) update {
	BOOL ready = [[model originalText] length] > 0;
	
	[copyButton setEnabled:[[model translation] length] > 0];
	[translateButton setEnabled:ready];
	
	if (ready) {
		[self translate];
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
		} else {
			// TODO: crash here
			NSLog(@"Unexpected item: %@", e);
		}
	}
}

- (void)setSourceLanguage:(id)aSender {
#ifndef NDEBUG
	NSLog(@"setSourceLanguage:\"%@\"", aSender);	
#endif
	
	[model setSelectedSourceLanguage:[[sourceLanguagePopup selectedItem] representedObject]];
}

- (void)setTargetLanguage:(id)aSender {
#ifndef NDEBUG
	NSLog(@"setTargetLanguage:\"%@\"", aSender);
#endif
	
	[model setSelectedTargetLanguage:[[targetLanguagePopup selectedItem] representedObject]];
}

- (void)translate {
	NSString* text = [model originalText];
	Language *from = [model selectedSourceLanguage];
	Language *to = [model selectedTargetLanguage];
	NSObject<Translator> *translator = [model translator];
	
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
	
	[copyButton setEnabled:NO];
}

- (void)translationOperationDidFinish:(id)aNotification {
#ifndef NDEBUG
	NSLog(@"translationOperationDidFinish: %@", aNotification);
#endif
	
	[progressIndicator stopAnimation:nil];
	[copyButton setEnabled:YES];
	
	[translatedTextViewDisclosureTriangle setState:NSOnState];
	[self showHideTranslationViewAction:translatedTextViewDisclosureTriangle];
	
	TranslateTextOperation *operation = [aNotification object];
	// TODO: assert operation != nil
	if ([operation error]) {
		[NSApp presentError:[operation error]];
		return;
	}
	
	[model setTranslation:[operation translation]];
}

- (IBAction)translateTextAction:(id)aSender {
	[self translate];
}

- (IBAction)copyTranslationAction:(id)aSender {
#ifndef NDEBUG
	NSLog(@"copyTranslation:\"%@\"", aSender);
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

- (void)closeWindowAction:(id)aSender {
#ifndef NDEBUG
	NSLog(@"closeWindow:\"%@\"", aSender);
#endif
	
	// close window
	[self close];
}

- (IBAction)showHideTranslationViewAction:(id)aSender {
#ifndef NDEBUG
	NSLog(@"showHideTranslationViewAction:\"%@\"", aSender);
#endif
	
    NSWindow *window = [translatedTextViewContainer window];
    NSRect frame = [window frame];
	NSLog(@"o: %f %f", frame.size.height, frame.origin.y);
    // The extra +14 accounts for the space between the box and its neighboring views
	NSRect rect = [translatedTextViewContainer frame];
    CGFloat sizeChange = rect.size.height;// + 14;
		
    switch ([translatedTextViewDisclosureTriangle state]) {
        case NSOnState:
            // Make the window bigger.
            frame.size.height += sizeChange;
            // Move the origin.
            frame.origin.y -= sizeChange;
			// resize
			[window setFrame:frame display:YES animate:YES];
            // Show the extra box.
            [translatedTextViewContainer setHidden:NO];
            break;
        case NSOffState:
            // Hide the extra box.
            [translatedTextViewContainer setHidden:YES];
            // Make the window smaller.
            frame.size.height -= sizeChange;
            // Move the origin.
            frame.origin.y += sizeChange;
			// resize
			[window setFrame:frame display:YES animate:YES];
            break;
        default:
            break;
    }
	NSLog(@"o: %f %f", frame.size.height, frame.origin.y);
}

@end