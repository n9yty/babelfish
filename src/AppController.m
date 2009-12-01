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

#import "AppController.h"
#import "GoogleTranslator.h"
#import "TranslateTextOperation.h"
#import "LanguageManager.h"
#import "version.h"

// TODO: logging
@implementation AppController

- (id)init {
	if (![super init]) {
		return nil;
	}

#ifndef NDEBUG
	NSLog(@"Initializing %@ build number %@", [AppController class], [NSNumber numberWithInt:BUILD_NUMBER]);
#endif
	
	translator = [[GoogleTranslator alloc] init];		
	operationQueue = [[NSOperationQueue alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(translationOperationDidFinished:) name:TRANSLATION_FINISHED_NOTIFICATION object:nil];
	
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [AppController class]);
#endif
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[operationQueue cancelAllOperations];
	[operationQueue release];	
	[translator release];
	[lastTranslation release];
	
	[super dealloc];
}

- (void)awakeFromNib {
#ifndef NDEBUG
	NSLog(@"Main Nib has been loaded");
#endif
	// TODO: loading preferences goes here
	
	[progressIndicator setDisplayedWhenStopped:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#ifndef NDEBUG
	NSLog(@"Registering self as a service service");
#endif
		
	[NSApp setServicesProvider:self];	
}

- (void)showBusyTranslationPanel {	
#ifndef NDEBUG
    NSLog(@"showBusyTranslationPanel"); 
#endif
	
	// hide the text - also with the enclosing scroll view
	[[translatedText enclosingScrollView] setHidden:YES];
	[useButton setHidden:YES];
	[fromImage setHidden:YES];
	[toImage setHidden:YES];
	[fromBox setHidden:YES];
	[toBox setHidden:YES];
	
	// start progress animation
	[progressIndicator startAnimation:self];

	// show the vindow if it has not been shown before
	if (![translationWindow isVisible]) {
		NSLog(@"showing window");
		// center the window relativelly to screen
		[translationWindow center];
		// show as a key window
		[translationWindow makeKeyAndOrderFront:self];
	}	
}

- (void)showTranslation:(NSString *)translation from:(Language *)from to:(Language *)to {
#ifndef NDEBUG
	NSLog(@"showTranslation:\"%@\" from:\"%@\" to:\"%@\"", translation, from, to);
#endif

	// TODO: check arguments
	// TODO: make sure window is visible
	// TODO: sync

	// save the translation
	if (lastTranslation != translation) {
		[lastTranslation release];
	}
	lastTranslation = [translation retain];

	// stop the animation
	[progressIndicator stopAnimation:self];	
		
	// set the translation
	[translatedText setString:translation];
	// set from image
	[fromImage setImage: [from image]];
	// set to image
	[toImage setImage: [to image]];
	// show boxes
	[fromBox setHidden:NO];
	[toBox setHidden:NO];
	
	// TODO: set default color
	// show text
	[[translatedText enclosingScrollView] setHidden:NO];
	// show the copy button
	[useButton setHidden:NO];
	
	// set copy button to have a focus
	[translationWindow setInitialFirstResponder:useButton];	
}

- (void)showError:(NSString *)error {
#ifndef NDEBUG
	NSLog(@"showError:\"%@\"", error);
#endif

	// TODO: check argument
	// TODO: make sure window is visible
	
	// stop the animation
	[progressIndicator stopAnimation:self];	
	// set the error
	[translatedText setString:error];
	// TODO: set error color
	// show text
	[[translatedText enclosingScrollView] setHidden:NO];
	// hide copy button
	[useButton setHidden:YES];
	[fromImage setHidden:YES];
	[toImage setHidden:YES];
	[fromBox setHidden:YES];
	[toBox setHidden:YES];
	
}

- (IBAction)useTranslation:(id)sender {
#ifndef NDEBUG
	NSLog(@"useTranslation:\"%@\"", sender);
#endif

	// TODO: this should be synchronized	
	NSString *string = [lastTranslation copy];
	if (string == nil) {
		return;
	}
		
	// copy to pasteboard
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pboard setString:string forType:NSStringPboardType];
	
	[string release];
	
	// hide window
	[translationWindow orderOut:self];
}

- (void)closeWindow:(id)sender {
#ifndef NDEBUG
	NSLog(@"closeWindow:\"%@\"", sender);
#endif

	// hide window
	[translationWindow orderOut:sender];
}

/*
 * the error is ignore here as if there will be an error it will be displayed in a window anyway
 */
-(void)translateText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
#ifndef NDEBUG
	NSLog(@"translateText:\"%@\" userData:\"%@\" error:\"%@\"", pboard, userData, error);
#endif

	// userData is really the only one to check as the others are defined by the service protocol
	if (userData == nil) {
		*error = NSLocalizedString(@"Error: service description does not provide a language pair.", nil);
		return;
	}
	
	// extract the language pair
	NSArray *languagePair = [userData componentsSeparatedByString:@"-"];
	if ([languagePair count] != 2) {
		*error = NSLocalizedString(@"Error: service description does not provide a language pair.", nil);
		return;
	}

	Language *from = [[LanguageManager languageManager] languageByCode:[languagePair objectAtIndex:0]];
	if (!from) {
		*error = NSLocalizedString(@"Error: from language is not supported.", nil);
		return;
	}
	
	Language *to = [[LanguageManager languageManager] languageByCode:[languagePair objectAtIndex:1]];
	if (!to) {
		*error = NSLocalizedString(@"Error: to language is not supported.", nil);
		return;
	}
	
	if (from == to) {
		*error = NSLocalizedString(@"Error: from and to languages are the same. This does not make much sense, does it?", nil);
		return;
	}
	
	// check for string in pasteboard
    NSArray *types = [pboard types];
    if (![types containsObject:NSStringPboardType]) {
        *error = NSLocalizedString(@"Error: no string found in the paste board.", nil);
        return;
    }
	
	// get the string - this will return the selected text
    NSString *text = [pboard stringForType:NSStringPboardType];
	// TODO: check white characters
    if (!text || [text length] == 0) {
        *error = NSLocalizedString(@"Error: no string found in the paste board.", nil);
        return;
    }

	// do the actual transaltion
	[self translateText:text from:from to:to];
		
	return;
}

- (void)translateText:(NSString *)text from:(Language *)from to:(Language *)to {
#ifndef NDEBUG
	NSLog(@"translateText:\"%@\" from:\"%@\" to:\"%@\"", text, from, to);
#endif
	
	// cancel all pending translation (should be at max one)
	[operationQueue cancelAllOperations];
	
	// show translation panel
	[self showBusyTranslationPanel];
	
	// create a new translation operation
	TranslateTextOperation *operation = [[TranslateTextOperation alloc] initWithText:text from:from to:to translator:translator];
	// enqueue
	[operationQueue addOperation:operation];
}

- (void)translationOperationDidFinished:(id)notification {
#ifndef NDEBUG
	NSLog(@"translationOperationDidFinished:\"%@\"", notification);
#endif
	
	@try {
		// get the translation - if any
		// TODO: should I release the object?
		TranslateTextOperation *operation = [notification object];
		
		// show
		[self showTranslation:[operation translation] from:[operation from] to:[operation to]];		
	} @catch (NSException *e) {
		NSString *error = [NSString stringWithFormat:@"Unable to translate text: %@: %@", [e name], [e reason]];
		// log the error
		NSLog(error);
		// and display it
		[self showError:error];
	}
}

@end