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

#import "BFTranslateTextOperation.h"
#import "BFLanguage.h"
#import "BFDefines.h"

NSString *const BFTranslationFinishedNotificationKey = @"BFTranslationFinishedNotificationKey";

@implementation BFTranslateTextOperation

@synthesize from;
@synthesize to;
@synthesize translation;
@synthesize error;

- (id) initWithText:(NSString *)aText from:(BFLanguage *)fromLang to:(BFLanguage *)toLang translator:(NSObject<BFTranslator> *)aTranslator {	
	if (![super init]) {
		return nil;
	}
	
	// TODO: check arguments
	
	text = [aText retain];
	from = [fromLang retain];
	to = [toLang retain];
	translator = [aTranslator retain];
	
	return self;
}

- (void) dealloc {
	[text release];
	[from release];
	[to release];
	[translation release];
	[error release];
	
	[super dealloc];
}

- (void) main {
	BFDevLog(@"Translating text operation:\"%@\" from:\"%@\" to:\"%@\" using %@", text, from, to, [translation description]);

	NSString *t = [translator translateText:text from:[from code] to:[to code] error:&error];
	
	if (t == nil) {
		BFDevLog(@"Translation error: %@", error);
	} else {
		BFDevLog(@"Translation: %@", t);
	}
	
	translation = [t retain];
	if (error) {
		[error retain];
	}
	
	if (![self isCancelled]) {
		[[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject: [NSNotification notificationWithName:BFTranslationFinishedNotificationKey object:self] waitUntilDone:NO];
	}
	
}

@end
