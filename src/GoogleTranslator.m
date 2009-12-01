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

- (NSString*)translateText:(NSString*)text from:(NSString*)from to:(NSString*)to {
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
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
	
	// check if something did happened
	if (data == nil) {
		@throw [NSException
				exceptionWithName:@"NoResponseFromServerException"
				reason:[NSString stringWithFormat:@"Did not get any respose from the server: %@ %@", requestUrl, error != nil ? [error description] : @"unknown error"]
				userInfo:nil];
	} 
	
	NSString* contents = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
	[contents autorelease];
	// the answer is in this kind of format decode:
	// {"responseData": {
	//		"translatedText":"Ciao mondo"
	//	},
	//  "responseDetails": null, 
	//  "responseStatus": 200}
	
	NSDictionary *result = [parser objectWithString:contents error:&error];
 	
	if (result == nil) {
		@throw [NSException
				exceptionWithName:@"InvalidResponseException"
				reason:[NSString stringWithFormat:@"Received invalid response %@", [error description]]
				userInfo:[NSDictionary dictionaryWithObject:contents forKey:@"response"]];
	}
	
	// there could be a problem - so check for correct error code
	int responseStatus = [[result objectForKey:@"responseStatus"] intValue];
	if (responseStatus != 200) {
		NSString *responseDetails = [result objectForKey:@"responseDetails"];
		@throw [NSException
				exceptionWithName:@"RequestFailedException"
				reason:[NSString stringWithFormat:@"Request failed with error code %d (%@)", responseStatus, responseDetails]
				userInfo:nil];
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

- (NSString *)description {
	return [NSString stringWithFormat:@"Google Translator (%@)", GOOGLE_TRANSLATE_URL];
}

@end
