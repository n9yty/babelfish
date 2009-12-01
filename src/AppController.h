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

@class TranslationController;
@class TranslateTextOperation;
@class Language;

@interface AppController : NSObject {
	IBOutlet NSPanel *translationWindow;
	IBOutlet NSTextView *translatedText;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *useButton;
	IBOutlet NSButton *closeButton;
	IBOutlet NSImageView *fromImage;
	IBOutlet NSImageView *toImage;
	IBOutlet NSView *fromBox;
	IBOutlet NSView *toBox;
	
@private
	NSString *lastTranslation;
	NSObject<Translator> *translator;
	NSOperationQueue *operationQueue;
}

- (void)showBusyTranslationPanel;
- (void)showTranslation:(NSString *)translation from:(Language *)from to:(Language *)to;
- (void)showError:(NSString *)error;

- (void)translateText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error;
- (void)translateText:(NSString *)text from:(Language *)from to:(Language *)to;

- (void)translationOperationDidFinished:(id)notification;

- (IBAction)useTranslation:(id)sender;
- (IBAction)closeWindow:(id)sender;

@end