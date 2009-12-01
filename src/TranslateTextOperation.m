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

//  Created by Filip Krikava on 11/29/09.

#import "TranslateTextOperation.h"
#import "LanguageManager.h"

@implementation TranslateTextOperation

- (id) initWithText:(NSString *)text from:(Language *)from to:(Language *)to translator:(NSObject<Translator> *)translator {
#ifndef NDEBUG
	NSLog(@"Initializing %@", [TranslateTextOperation class]);
#endif
	
	if (![super init]) {
		return nil;
	}
	
	// TODO: check arguments
	
	_text = [text retain];
	_from = [from retain];
	_to = [to retain];
	_translator = [translator retain];
	
	return self;
}

- (void) dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [TranslateTextOperation class]);
#endif
	
	[_text release];
	[_from release];
	[_to release];
	[_translator release];
	[_translation release];
	[_exception release];
	
	[super dealloc];
}

- (void) main {
#ifndef NDEBUG
	NSLog(@"Translating text:\"%@\" from:\"%@\" to:\"%@\" using %@", _text, _from, _to, [_translator description]);
#endif
	@try {
		// translate
		NSString *translation = [_translator translateText:_text from:[_from code] to:[_to code]];
		
		if (translation == nil) {
			@throw [NSException exceptionWithName:@"NilTranslation" reason:@"Translator returned no trsnaltion" userInfo:nil];
		}
		
#ifndef NDEBUG
		NSLog(@"Translation: %@", translation);
#endif	
		
		_translation = [translation retain];		
	} @catch (NSException *e) {
		NSString *error = [NSString stringWithFormat:@"Unable to translate text: %@: %@", [e name], [e reason]];
		NSLog(error);

		_exception = e;
	} @finally {
		if (![self isCancelled]) {
			[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject: [NSNotification notificationWithName:TRANSLATION_FINISHED_NOTIFICATION object:self] waitUntilDone:NO];
		}
	}
}

- (NSString *) translation {
	if (_exception == nil) {
		return _translation;
	} else {
		@throw _exception;
	}
}

- (Language *) from {
	return _from;
}

- (Language *) to {
	return _to;
}

@end
