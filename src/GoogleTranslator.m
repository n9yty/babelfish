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
#import "GoogleTranslator.h"

@implementation GoogleTranslator

NSString *const BFTranslatorErrorDomainKey = @"net.nkuyu.babelfishapp.ErrorDomain";

NSInteger const BFNoResponseErrorCodeKey = 1;
NSInteger const BFInvalidResponseErrorCodeKey = 2;
NSInteger const BFServiceFailedErrorCodeKey = 3;

- (id) init {
	if(![super init]) {
		return nil;
	}
	
#ifndef NDEBUG
	NSLog(@"Initializing %@", [GoogleTranslator class]);
#endif
	
	// create the JSON parser
	parser = [[SBJSON alloc] init];	
	
	return self;
}

- (void) dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [GoogleTranslator class]);
#endif

	[parser release];
	
	[super dealloc];
}

- (NSString*)translateText:(NSString*)text from:(NSString*)from to:(NSString*)to error:(NSError **)error{
	// TODO: check the arguments
	// TODO: how about all these string - should I release them ;)
	// compose the URL string
	// expected URL is like: http://ajax.googleapis.com/ajax/services/language/translate?v=1.0&q=hello%20world&langpair=en%7Cit
	NSString* encodedText = [text stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString* langPair = [[NSString stringWithFormat:@"%@|%@", from, to] stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSString* requestUrl = [NSString stringWithFormat:@"%@&q=%@&langpair=%@", GOOGLE_TRANSLATE_URL, encodedText, langPair];
	
	NSLog(@"Making call to google translate %@", requestUrl);
	
	// make the call
	NSURL* url = [NSURL URLWithString: requestUrl];
	NSURLRequest* request = [NSURLRequest requestWithURL: url cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval: TIMEOUT];
	NSURLResponse* response = nil; 
	NSError *underlyingError = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &underlyingError];
	
	// check if something did happened
	if (data == nil) {
		[self raiseError:error code:BFNoResponseErrorCodeKey description:@"No response from translation service" underlyingError:underlyingError];
		return nil;
		// reason:[NSString stringWithFormat:@"Did not get any respose from the server: %@ %@", requestUrl, error != nil ? [error description] : @"unknown error"]
	} 
	
	NSString* contents = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	[contents autorelease];
	
	// the answer is in this kind of format decode:
	// {"responseData": {
	//		"translatedText":"Ciao mondo"
	//	},
	//  "responseDetails": null, 
	//  "responseStatus": 200}
	
	NSDictionary *result = [parser objectWithString:contents error:&underlyingError];
 	
	if (result == nil) {
		[self raiseError:error code:BFInvalidResponseErrorCodeKey description:@"Invalid response from translation service" underlyingError:underlyingError];
		return nil;
		// reason:[NSString stringWithFormat:@"Received invalid response %@", [error description]]
	}
	
	// there could be a problem - so check for correct error code
	int responseStatus = [[result objectForKey:@"responseStatus"] intValue];
	if (responseStatus != 200) {
		NSString *responseDetails = [result objectForKey:@"responseDetails"];
		
		[self raiseError:error code:BFServiceFailedErrorCodeKey description:@"Translation service failed" reason:[NSString stringWithFormat:@"Request failed with error code %d (%@)", responseStatus, responseDetails]];
		return nil;
	} 
	
	// get the translation
	NSDictionary *responseData = [result objectForKey:@"responseData"];
	NSString *translatedText = [responseData objectForKey:@"translatedText"];

	// UTF-8
	translatedText = [translatedText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	// '
	translatedText = [translatedText stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
	
	return translatedText;
}

- (void) raiseError:(NSError **)error code:(NSInteger)code description:(NSString *)description reason:(NSString*)reason {
	NSDictionary *d = [NSDictionary dictionary];
	[d setValue:description forKey:NSLocalizedDescriptionKey];
	[d setValue:reason forKey:NSLocalizedFailureReasonErrorKey];
	
	*error = [[[NSError alloc] initWithDomain:BFTranslatorErrorDomainKey code:code userInfo:d] autorelease];
}

- (void) raiseError:(NSError **)error code:(NSInteger)code description:(NSString *)description underlyingError:(NSError*)underlyingError {

	NSDictionary *d = [NSDictionary dictionary];
	[d setValue:description forKey:NSLocalizedDescriptionKey];
	[d setValue:underlyingError forKey:NSUnderlyingErrorKey];
	
	*error = [[[NSError alloc] initWithDomain:BFTranslatorErrorDomainKey code:code userInfo:d] autorelease];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Google Translator (%@)", GOOGLE_TRANSLATE_URL];
}

@end
