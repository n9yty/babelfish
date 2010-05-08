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
#import "BFTranslationTask.h"
#import "BFDefines.h"

// NSString *const BFTranslationFinishedNotificationKey = @"BFTranslationFinishedNotificationKey";

@interface BFTranslateTextOperation (Private)
- (void) notify;
@end

@implementation BFTranslateTextOperation

@synthesize task;
@synthesize error;

- (id) initWithTask:(BFTranslationTask *)aTask translator:(NSObject<BFTranslator> *)aTranslator selector:(SEL) aSelector onObject:(id) anObject {
	BFAssert(aTask, @"task must not be null");
	BFAssert(aTranslator, @"translator must not be null");
	BFAssert(aSelector, @"selector must not be null");
	BFAssert(anObject, @"object must not be null");
	
	if (![super init]) {
		return nil;
	}
	
	// TODO: check arguments

	task = [aTask retain];
	translator = [aTranslator retain];
	selector = aSelector;
	provider = [anObject retain];
	
	return self;
}

- (void) dealloc {
	[task release];
	[translation release];
	[error release];
	[provider release];
	
	[super dealloc];
}

- (void) main {
	BFDevLog(@"Translatinng task:\"%@\" using %@", task, translation);

	NSString *t = [translator translateText:[task originalText] from:[task sourceLanguage] to:[task targetLanguage] error:&error];
	
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
		[self performSelectorOnMainThread:@selector(notify) withObject:nil waitUntilDone:YES];
	}	
}

@end

@implementation BFTranslateTextOperation (Private) 

- (void) notify {
	objc_msgSend(provider, selector, task, translation, error);
}

@end
