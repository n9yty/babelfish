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

// the actual part where stuff happens
// the userData variable contains the desired language pair in form of <from>|<to>
-(void)translateText:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error {		
	// userData is really the only one to check as the others are defined by the service protocol
	if (userData == nil) {
		*error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"userData does not contain language pair description in form of <from>|<to>. It is empty.");
	}
	
	// extract the language pair
	NSArray *languagePair = [userData componentsSeparatedByString:@"-"];
	if ([languagePair count] != 2) {
		*error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"userData does not contain language pair description in form of <from>|<to>");
	}
	
	// check for string in pasteboard
    NSArray *types = [pboard types];
    if (![types containsObject:NSStringPboardType]) {
        *error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"pboard couldn't give string.");
        return;
    }
	
	// get the string - this will return the selected text
    NSString *text = [pboard stringForType:NSStringPboardType];
    if (!text) {
        *error = NSLocalizedString(@"Error: couldn't translate text.",
								   @"pboard couldn't give string.");
        return;
    }
	
	@try {
		// translate
		NSString *translation = [Translator translateText:text from:[languagePair objectAtIndex:0] to:[languagePair objectAtIndex:1]];
		
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