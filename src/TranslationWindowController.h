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

#import <Cocoa/Cocoa.h>

#import "Translator.h"

@class Translation;
@class TranslateTextOperation;
@class BFTranslationWindowModel;
@class RatedLanguage;

@interface TranslationWindowController : NSWindowController {
	IBOutlet NSTextView *originalTextView;
	IBOutlet NSTextView *translatedTextView;
	IBOutlet NSButton *translatedTextViewDisclosureTriangle;
	IBOutlet NSView *translatedTextViewContainer;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *copyButton;
	IBOutlet NSButton *closeButton;
	IBOutlet NSButton *translateButton;
	IBOutlet NSPopUpButton *sourceLanguagePopup;
	IBOutlet NSPopUpButton *targetLanguagePopup;
	IBOutlet NSTextField *copyrightLabel;
		
@private
	NSOperationQueue *operationQueue;
	
	BFTranslationWindowModel* model;
}

@property (retain, readonly) BFTranslationWindowModel* model;

- (id)initWithModel:(BFTranslationWindowModel*) aModel;

- (void)translationOperationDidFinish:(id)aNotification;
- (void)populateMenu:(NSMenu *)menu withItems:(NSArray *)items;
- (void)update;
- (void)translate;

- (IBAction)setTargetLanguage:(id)aSender;
- (IBAction)setSourceLanguage:(id)aSender;
- (IBAction)copyTranslationAction:(id)aSender;
- (IBAction)closeWindowAction:(id)aSender;
- (IBAction)translateTextAction:(id)aSender;
- (IBAction)showHideTranslationViewAction:(id)aSender;


@end