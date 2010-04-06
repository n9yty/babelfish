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

#import <Cocoa/Cocoa.h>
#import "BFTranslator.h"

@class BFLanguage;

extern NSString *const BFTranslationFinishedNotificationKey;

@interface BFTranslateTextOperation : NSOperation {

@private
	NSString *text;
	BFLanguage *from;
	BFLanguage *to;
	NSObject<BFTranslator> *translator;
	
	NSString *translation;
	NSError *error;
}

- (id) initWithText:(NSString *)aText from:(BFLanguage *)fromLang to:(BFLanguage *)toLang translator:(NSObject<BFTranslator> *)aTranslator;

@property (readonly) NSString *translation;
@property (readonly) BFLanguage *from;
@property (readonly) BFLanguage *to;
@property (readonly) NSError *error;

@end
