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

@interface BFGoogleTranslatorTest : GHTestCase {
@private
	BFGoogleTranslator *translator;
	id invokerMock;
}

@end

@implementation BFGoogleTranslatorTest

// -- stubbing the actuall calls

-(NSData *) simpleWordTranslateRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	GHAssertEqualStrings(@"v=1.0&q=hello&langpair=en%7Cfr", [[request URL] query], @"URLs must be the same");
	
	return [@"{\"responseData\": {\"translatedText\":\"translated_hello\"}, \"responseDetails\": null, \"responseStatus\": 200}" dataUsingEncoding:NSUTF8StringEncoding];
}

-(NSData *) newLinesRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	NSLog(@"%@", [request URL]);
	//GHAssertEqualStrings(@"v=1.0&q=hello&langpair=en%7Cfr", [[request URL] query], @"URLs must be the same");
	
	return [@"{\"responseData\": {\"translatedText\":\"translated_text line 1 \\u003cBR\\u003e text line 3 \\u003cBR\\u003e\\u003cBR\\u003e text line 6\"}, \"responseDetails\": null, \"responseStatus\": 200}" dataUsingEncoding:NSUTF8StringEncoding];	
}

// -- set up / tear down code

-(void)setUp {
	invokerMock = [OCMockObject mockForProtocol:@protocol(BFHTTPInvoker)];
	translator = [[BFGoogleTranslator alloc] initWithHTTPInvoker:invokerMock];
}

-(void)tearDown {
	[translator release];
}

// -- actualTest

-(void) testSimpleWordTranslate {
	[[[invokerMock stub] andCall:@selector(simpleWordTranslateRequest:returningResponse:error:) onObject:self] syncInvokeRequest:[OCMArg any] returningResponse:[OCMArg anyPointer] error:[OCMArg anyPointer]];
	
	NSError *error = nil;
	NSString *translation = [translator translateText:@"hello" from:@"en" to:@"fr" error:&error];
	
	[invokerMock verify];
	
	GHAssertNil(error, @"No error should be set up");
	GHAssertEqualStrings(@"translated_hello", translation, @"Translation failed");
}

-(void) testNewLines {
	[[[invokerMock stub] andCall:@selector(newLinesRequest:returningResponse:error:) onObject:self] syncInvokeRequest:[OCMArg any] returningResponse:[OCMArg anyPointer] error:[OCMArg anyPointer]];
	
	NSError *error = nil;
	NSString *translation = [translator translateText:@"text line 1\ntext line 3\n\ntext line 6" from:@"en" to:@"fr" error:&error];
	
	[invokerMock verify];
	
	GHAssertNil(error, @"No error should be set up");
	GHAssertEqualStrings(@"translated_text line 1\ntext line 3\n\ntext line 6", translation, @"Translation failed");
}


@end
