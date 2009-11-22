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

#import "BabelfishService.h"
#import "Translator.h"

// this is where the services gets defined
@implementation BabelfishService

// French -> English
-(void)translateFrenchToEnglish:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {	
	[self doTranslate:pboard userData:userData error:error from:@"fr" to:@"en"];
}

// English -> French
-(void)translateEnglishToFrench:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {
	[self doTranslate:pboard userData:userData error:error from:@"en" to:@"fr"];
}

// the actual part where stuff happens
-(void)doTranslate:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error from:(NSString *)from to:(NSString *)to {	
	NSString *pboardString;
    NSArray *types;
	
	// check for string in pasteboard
    types = [pboard types];
    if (![types containsObject:NSStringPboardType]) {
        *error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"pboard couldn't give string.");
        return;
    }
	
	// get the string - this will return the selected text
    pboardString = [pboard stringForType:NSStringPboardType];
    if (!pboardString) {
        *error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"pboard couldn't give string.");
        return;
    }
	
	@try {
		// translate
		NSString *translation = [Translator translateText:pboardString from:from to:to];
		
		// set resulting type
		types = [NSArray arrayWithObject:NSStringPboardType];
		[pboard declareTypes:types owner:nil];
		// encode
		[pboard setString:translation forType:NSStringPboardType];
	} @catch (NSException *e) {
		*error = [NSString stringWithFormat:@"Unable to translate text: %@: %@", [e name], [e reason]];
	}
	
	return;
}

@end
