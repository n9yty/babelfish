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

#import "BFTranslator.h"
#import "BFDefines.h"

@class BFTranslateTextOperation;
@class BFTranslationWindowModel;
@class BFLanguage;
@class BFUserDefaults;

@interface BFTranslationWindowController : NSWindowController {
	IBOutlet NSBox *translationBox;
	IBOutlet NSTextView *originalTextView;
	IBOutlet NSTextView *translatedTextView;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *copyAndCloseButton;
	IBOutlet NSButton *translateButton;
	IBOutlet NSButton *swapLanguagesButton;
	IBOutlet NSPopUpButton *sourceLanguagePopup;
	IBOutlet NSPopUpButton *targetLanguagePopup;
	IBOutlet NSTextField *copyrightLabel;
		
@private	
	BFTranslationWindowModel* model;
	BFUserDefaults *userDefaults;
}

@property (retain, readonly) BFTranslationWindowModel* model;

- (id)initWithModel:(BFTranslationWindowModel*) aModel userDefaults:(BFUserDefaults*)aUserDefaults;

- (void)translationOperationDidFinish:(id)aNotification;
- (void)populateMenu:(NSMenu *)menu withItems:(NSArray *)items;
- (void)translate;
- (void)setTranslationBoxHidden:(BOOL)hidden;

- (void)handleOriginalTextChanged;
- (void)handleLanguageSelectionChanged;
- (void)handleTranslationChanged;	

- (void)startTranslateTimer;
- (void)stopTranslateTimer;
- (void)translateTimerDidFire:(NSTimer *)aTimer;

- (NSArray *) sourceLanguagesMenu;
- (NSArray *) targetLanguagesMenu;

- (IBAction)setTargetLanguage:(id)aSender;
- (IBAction)setSourceLanguage:(id)aSender;
- (IBAction)copyTranslationAndCloseAction:(id)aSender;
- (IBAction)translateTextAction:(id)aSender;
- (IBAction)swapLanguages:(id)aSender;

@end