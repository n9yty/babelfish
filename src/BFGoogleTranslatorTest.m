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

//  Created by Filip Krikava on 11/20/09.

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

#import "BFGoogleTranslator.h"
#import "BFTranslator.h"
#import "BFHTTPInvoker.h"
#import "BFTestHelper.h"

@interface BFGoogleTranslatorTest : GHTestCase {
@private
	BFGoogleTranslator *translator;
	id invokerMock;
}

@end

@implementation BFGoogleTranslatorTest

// -- set up / tear down code

- (void)setUpClass {
	BFTestHelperInitialize();
}

-(void)setUp {
	invokerMock = [OCMockObject mockForProtocol:@protocol(BFHTTPInvoker)];
	translator = [[BFGoogleTranslator alloc] initWithHTTPInvoker:invokerMock];
}

-(void)tearDown {
	[translator release];
}

// -- actualTest

-(void) testSimpleWordTranslate {
	NSData *responseData = [@"{\"responseData\": {\"translatedText\":\"translated_hello\"}, \"responseDetails\": null, \"responseStatus\": 200}" dataUsingEncoding:NSUTF8StringEncoding];
	[[[invokerMock stub] andReturn:responseData] syncInvokeRequest:[OCMArg checkWithBlock:^BOOL(NSURLRequest *request) {
		return [@"v=1.0&q=hello&langpair=en%7Cfr" isEqual:[[request URL] query]];
	}]  returningResponse:[OCMArg anyPointer] error:[OCMArg anyPointer]];
	
	NSError *error = nil;
	NSString *translation = [translator translateText:@"hello" from:english to:french error:&error];
		
	GHAssertNil(error, @"No error should be set up");
	GHAssertEqualStrings(@"translated_hello", translation, @"Translation failed");
}

@end
