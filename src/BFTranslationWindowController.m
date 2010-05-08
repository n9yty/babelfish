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
#import "BFTranslationModel.h"
#import "BFTranslationTask.h"
#import "BFConstants.h"

@implementation BFTranslationWindowController

@synthesize originalText;
@synthesize translatedText;
@synthesize sourceLanguage;
@synthesize targetLanguage;

static NSString const* BFOriginalTextChangedCtxKey = @"BFOriginalTextChangedCtxKey";
static NSString const* BFTranslationChangedCtxKey = @"BFTranslationChangedCtxKey";
static NSString const* BFSourceLanguageChangedCtxKey = @"BFSourceLanguageChangedCtxKey";
static NSString const* BFTargetLanguageChangedCtxKey = @"BFTargetLanguageChangedCtxKey";

static NSTimeInterval const BFDelayBetweenTranslations = 1.0;
static NSInteger const BFMaxTextSizeForInteractiveTranslation = 1024;

- (id)initWithModel:(BFTranslationModel*)aModel {	
	if (![super initWithWindowNibName:@"TranslationWindow"]) {
		return nil;
	}
		
	model = [aModel retain];
	
	[self addObserver:self forKeyPath:@"originalText" options:NSKeyValueObservingOptionNew context:&BFOriginalTextChangedCtxKey];
	[self addObserver:self forKeyPath:@"translatedText" options:NSKeyValueObservingOptionNew context:&BFTranslationChangedCtxKey];
	[self addObserver:self forKeyPath:@"sourceLanguage" options:NSKeyValueObservingOptionNew context:&BFSourceLanguageChangedCtxKey];
	[self addObserver:self forKeyPath:@"targetLanguage" options:NSKeyValueObservingOptionNew context:&BFTargetLanguageChangedCtxKey];
	
	// set source language
	NSString* languageName = [[model lastUsedSourceLanguagesNames] objectAtIndex:0];
	BFLanguage *language = languageName ? [model languageByName:languageName] : nil;
	if (!language) {
		language = [model autoDetectTargetLanguage];
	}
	BFAssert(language, @"source language has to be set");
	[self setSourceLanguage:language];
	
	// set target language
	languageName = [[model lastUsedTargetLanguagesNames] objectAtIndex:0];
	language = languageName ? [model languageByName:languageName] : nil;
	
	if (!language) {
		// TODO: get language close to the local settings
		language = [[[model languages] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[BFConstants BFNameSortDescriptor]]] objectAtIndex:0];
	}
	BFAssert(language, @"target language has to be set");
	[self setTargetLanguage:language];

	return self;
}

- (void)dealloc {	
	[model release];
	
	[originalText dealloc];
	[translatedText dealloc];
	
	[sourceLanguage dealloc];
	[targetLanguage dealloc];
	
	[super dealloc];
}

- (void)awakeFromNib {
	// we start with no translation
	[self setTranslationBoxHidden:YES];
	
	// source languages
	[sourceLanguagePopup removeAllItems];
	[self populateMenu:[sourceLanguagePopup menu] withItems:[self sourceLanguagesMenu]];
		
	// target langages
	[targetLanguagePopup removeAllItems];
	[self populateMenu:[targetLanguagePopup menu] withItems:[self targetLanguagesMenu]];
	
	[self handleOriginalTextChanged];
	[self handleLanguageSelectionChanged];
	[self handleTranslationChanged];
}

- (void) handleLanguageSelectionChanged {
	// update swap button status
	[swapLanguagesButton setHidden:sourceLanguage == [model autoDetectTargetLanguage]];

	// synchronize source language - FIXME issue#2
	if (![[[sourceLanguagePopup selectedItem] representedObject] isEqual:sourceLanguage]) {
		[sourceLanguagePopup selectItemWithTag:[sourceLanguage hash]];
	}
	
	// synchronize target language - FIXME issue#2
	if (![[[targetLanguagePopup selectedItem] representedObject] isEqual:targetLanguage]) {
		[targetLanguagePopup selectItemWithTag:[targetLanguage hash]];	
	}	

// should translate
//	if ([[model originalText] length] > 0) {
//		[self translate];
//	}
}

- (void) handleOriginalTextChanged {
	[translateButton setEnabled:!isEmpty(originalText)];	
}

- (void) handleTranslationChanged {
	[copyAndCloseButton setEnabled:!isEmpty(translatedText)];	
}

/**
 * Dispatching events method
 */
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == &BFOriginalTextChangedCtxKey) {
		[self handleOriginalTextChanged];
	} else if (context == &BFSourceLanguageChangedCtxKey || context == &BFTargetLanguageChangedCtxKey) {
		[self handleLanguageSelectionChanged];
	} else if (context == &BFTranslationChangedCtxKey) {
		[self handleTranslationChanged];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

/**
 * @return returns an array of source language order by the preferences.
 */
- (NSArray *) sourceLanguagesMenu {
	NSArray* languages = [model languages];
	
	NSMutableArray *array = [NSMutableArray array];
	
	// first is the auto-detect
	[array addObject:[model autoDetectTargetLanguage]];
	
	// separator
	[array addObject:[NSMenuItem separatorItem]];
	
	// last used ones
	NSMutableArray *lastUsed = [NSMutableArray array];
	for (NSString *name in [model lastUsedSourceLanguagesNames]) {
		[lastUsed addObject:[model languageByName:name]];
	}
	
	NSMutableArray *remaining = [NSMutableArray arrayWithArray:languages];
	if (!isEmpty(lastUsed)) {
		[array addObjectsFromArray:lastUsed];
		[remaining removeObjectsInArray:lastUsed];		
		// separator
		[array addObject:[NSMenuItem separatorItem]];
	}
	
	// all others
	[array addObjectsFromArray:[remaining sortedArrayUsingDescriptors:[NSArray arrayWithObject:[BFConstants BFNameSortDescriptor]]]];
	
	return [NSArray arrayWithArray:array];
}

- (NSArray *) targetLanguagesMenu {
	NSArray* languages = [model languages];
	
	NSMutableArray *array = [NSMutableArray array];
	
	// last used ones
	NSMutableArray *lastUsed = [NSMutableArray array];
	for (NSString *name in [model lastUsedTargetLanguagesNames]) {
		[lastUsed addObject:[model languageByName:name]];
	}

	NSMutableArray *remaining = [NSMutableArray arrayWithArray:languages];
	if (!isEmpty(lastUsed)) {
		[array addObjectsFromArray:lastUsed];
		[remaining removeObjectsInArray:lastUsed];
		// separator
		[array addObject:[NSMenuItem separatorItem]];
	}
	
	// all others
	[array addObjectsFromArray:[remaining sortedArrayUsingDescriptors:[NSArray arrayWithObject:[BFConstants BFNameSortDescriptor]]]];
	
	return [NSArray arrayWithArray:array];
}

- (void) populateMenu:(NSMenu *)menu withItems:(NSArray *)items {
	for (id e in items) {
		NSMenuItem *mi = nil;

		if ([e isKindOfClass:[NSMenuItem class]]) {
			mi = e;
		} else if ([e isKindOfClass: [BFLanguage class]]) {
			BFLanguage *l = (BFLanguage *)e;
			
			mi = [[NSMenuItem alloc] initWithTitle:[l name] action:nil keyEquivalent:@""];
			[mi autorelease];
			
			[mi setRepresentedObject:l];
			[mi setImage:[l image]];
			[mi setTag:[l hash]];
		} else {
			BFFail(@"Unexpected item: %@", e);
		}

		BFAssert(mi, @"menu item must not be nil");
		[menu addItem:mi];
	}
}

// TODO: private
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

- (void)swapLanguages {
	BFLanguage* source = sourceLanguage;
	BFLanguage* target = targetLanguage;
	
	if ([source isEqual:[model autoDetectTargetLanguage]]) {
		return;
	}
	
	[self setSourceLanguage: target];
	[self setTargetLanguage: source];	
}

- (void)translate {
	BFAssert(!isEmpty(originalText), @"original text must not be empty");
	BFAssert(sourceLanguage, @"source language must not be nil");
	BFAssert(targetLanguage, @"target language must not be nil");

	// show busy animation
	[progressIndicator startAnimation:nil];
	
	BFTranslationTask *task = [[BFTranslationTask alloc] initWithOriginalText:originalText sourceLanguage:sourceLanguage targetLanguage:targetLanguage];
	
	// translate
	[model translate:task andCall:@selector(taskTranslated:translation:error:) onObject:self];
}

- (void)taskTranslated:(BFTranslationTask *) task translation:(NSString *)translation error:(NSError *)error {
	// stop busy animation
	[progressIndicator stopAnimation:nil];
	
	if (error) {
		// TODO: to retry count?
		
		[NSApp presentError:error];
		return;
	}
	
	// TODO: handle detected language
	
	[self setTranslatedText:translation];
	[self setTranslationBoxHidden:NO];	
}
	
- (IBAction)setSourceLanguageFromMenu:(id)aSender {
	BFLanguage* language = [[sourceLanguagePopup selectedItem] representedObject];
	
	if (![sourceLanguage isEqual:language]) {
		[self setSourceLanguage:language];
	}
}

- (IBAction)setTargetLanguageFromMenu:(id)aSender {
	BFLanguage* language = [[targetLanguagePopup selectedItem] representedObject];
	
	if (![targetLanguage isEqual:language]) {
		[self setTargetLanguage:language];
	}
}

- (IBAction)translateTextAction:(id)aSender {
	[self translate];
}

- (IBAction)copyTranslationAndCloseAction:(id)aSender {
	// TODO: this should be synchronized	
	NSString *string = [translatedText copy];
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
	[self swapLanguages];
}

@end