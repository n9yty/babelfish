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
#import "BFUserDefaults.h"
#import "BFStringConstants.h"

@interface BFTranslationWindowModelTest : GHTestCase {
	id userDefaultsMock;
	id translatorMock;
}

@end

static BFLanguage *autoDetect;
static BFLanguage *africans;
static BFLanguage *english;
static BFLanguage *french;

@implementation BFTranslationWindowModelTest

// -- set up / tear down code

- (void)setUpClass {
	autoDetect = [[BFLanguage alloc] initWithCode:@"" name:@"Auto" imagePath:@""];
	africans = [[BFLanguage alloc] initWithCode:@"af" name:@"Africans" imagePath:@""];
	english = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];
	french = [[BFLanguage alloc] initWithCode:@"fr" name:@"French" imagePath:@""]; 
}

-(void)setUp {
	userDefaultsMock = [[OCMockObject mockForClass:[BFUserDefaults class]] retain];
	translatorMock = [[OCMockObject mockForProtocol:@protocol(BFTranslator)] retain];
	
	[[[translatorMock stub] andReturn:africans] languageByName:[africans name]];
	[[[translatorMock stub] andReturn:english] languageByName:[english name]];
	[[[translatorMock stub] andReturn:french] languageByName:[french name]];
	[[[translatorMock stub] andReturn:autoDetect] autoDetectTargetLanguage];
}

-(void)tearDown {
	[userDefaultsMock release];
	userDefaultsMock = nil;
	
	[translatorMock release];
	translatorMock = nil;
}

// -- helpers

- (void) prepareEmptyLastUsedLanguageDefaults {
	[[[userDefaultsMock expect] andReturn:nil] lastUsedSourceLanguagesNames];
	[[[userDefaultsMock expect] andReturn:nil] lastUsedTargetLanguagesNames];
	
}

// -- actualTest

- (void)testInitializationDefaults {
	// prepare mocks
	[self prepareEmptyLastUsedLanguageDefaults];
	
	[[[translatorMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];

	// test
	BFTranslationWindowModel *model = [[BFTranslationWindowModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
		
	GHAssertEquals(autoDetect, [model selectedSourceLanguage], @"invalid source language selected");	
	GHAssertEquals(africans, [model selectedTargetLanguage], @"invalid target language selected");	
}

- (void)testInitializationDefaultsWithUserDefaults {
	// prepare mocks	
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedSourceLanguagesNames];
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[french name], [english name], nil]] lastUsedTargetLanguagesNames];

	// test
	BFTranslationWindowModel *model = [[BFTranslationWindowModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
		
	GHAssertEquals(english, [model selectedSourceLanguage], @"invalid source language selected");	
	GHAssertEquals(french, [model selectedTargetLanguage], @"invalid target language selected");	
}

- (void)testSwap {
	// prepare mocks
	[self prepareEmptyLastUsedLanguageDefaults];
	
	[[[translatorMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// test
	BFTranslationWindowModel *model = [[BFTranslationWindowModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
	[model setSelectedSourceLanguage:english];
	[model setSelectedTargetLanguage:french];
	[model swapLanguages];

	// verify
	GHAssertEquals(french, [model selectedSourceLanguage],@"invalid source languge after swap");
	GHAssertEquals(english, [model selectedTargetLanguage],@"invalid target languge after swap");
}

- (void)testSwapAutoDetectLanguage {
	[self prepareEmptyLastUsedLanguageDefaults];

	[[[translatorMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// test
	BFTranslationWindowModel *model = [[BFTranslationWindowModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
	[model setSelectedSourceLanguage:autoDetect];
	[model setSelectedTargetLanguage:french];
	
	[model swapLanguages];
	
	// verify
	GHAssertEquals(autoDetect, [model selectedSourceLanguage],@"invalid source languge after swap");
	GHAssertEquals(french, [model selectedTargetLanguage],@"invalid target languge after swap");
}


@end
