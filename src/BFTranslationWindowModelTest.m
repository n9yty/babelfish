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

#import "BFTranslator.h"
#import "BFLanguage.h"
#import "BFTranslationWindowModel.h"
#import "BFStringConstants.h"
#import "BFArgumentCheckUtils.h"

@interface BFTranslationWindowModelTest : GHTestCase {
@private
	BFTranslationWindowModel *model;
	id userDefaultsMock;
	id translatorMock;
}

@end

@implementation BFTranslationWindowModelTest

// -- set up / tear down code

-(void)setUp {
	userDefaultsMock = [OCMockObject mockForClass:[NSUserDefaults class]];
	translatorMock = [OCMockObject mockForProtocol:@protocol(BFTranslator)];
	model = [[BFTranslationWindowModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
}

-(void)tearDown {
	[model release];
}

// -- actualTest

- (void)testUserPreferencesLastUsedSourceLanguages {
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:@"English", @"French", nil]] arrayForKey:BFLastUsedSourceLanguagesKey];
	BFLanguage *languageEn = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];
	BFLanguage *languageFr = [[BFLanguage alloc] initWithCode:@"fr" name:@"French" imagePath:@""]; 
	
	[[[translatorMock stub] andReturn:languageEn] languageByName:@"English"];
	[[[translatorMock stub] andReturn:languageFr] languageByName:@"French"];

	NSArray *langs = [model lastUsedSourceLanguages];
	
	[userDefaultsMock verify];
	[translatorMock verify];
	
	GHAssertEquals([langs count], (NSUInteger)2, @"size must be 2");
	GHAssertTrue([langs containsObject:languageEn], @"english is not present");
	GHAssertTrue([langs containsObject:languageFr], @"french is not present");
}

- (void)testUserPreferencesAddLastUsedSourceLanguages {
	BFLanguage *languageEn = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];

	[[[userDefaultsMock stub] andReturn:nil] arrayForKey:BFLastUsedSourceLanguagesKey];	

	BFArgumentCheckUtils *util = [BFArgumentCheckUtils checkExpectedArray:[NSArray arrayWithObjects:[languageEn name],nil]];
	[[userDefaultsMock expect] setObject:[OCMArg checkWithSelector:@selector(checkArray:) onObject:util] forKey:BFLastUsedSourceLanguagesKey];

	[model setLastUsedSourceLanguage:languageEn];
	
	[userDefaultsMock verify];
}				  
				  
@end
