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
#import "BFTranslationModel.h"
#import "BFTestHelper.h"
#import "BFConstants.h"

@interface BFTranslationModelTest : GHTestCase {
	id userDefaultsMock;
	id translatorMock;
}

@end


@implementation BFTranslationModelTest

// -- set up / tear down code

- (void)setUpClass {
	BFTestHelperInitialize();		
}

-(void)setUp {
	userDefaultsMock = [[OCMockObject mockForClass:[NSUserDefaults class]] retain];
	translatorMock = [[OCMockObject mockForProtocol:@protocol(BFTranslator)] retain];
	
	BFTestHelperStubBasicTranslatorMethods(translatorMock);
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

- (void)testUserPreferencesLastUsedSourceLanguages {
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] arrayForKey:BFLastUsedSourceLanguagesKey];
	
	BFTranslationModel *model = [[BFTranslationModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
	NSArray *sourceLanguages = [model lastUsedSourceLanguagesNames];
	
	GHAssertEquals([sourceLanguages count], (NSUInteger)2, @"size must be 2");
	GHAssertTrue([sourceLanguages containsObject:[english name]], @"english is not present");
	GHAssertTrue([sourceLanguages containsObject:[french name]], @"french is not present");
}

- (void)testUserPreferencesLastUsedTargetLanguages {
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObject:[africans name]]] arrayForKey:BFLastUsedTargetLanguagesKey];
	
	BFTranslationModel *model = [[BFTranslationModel alloc] initWithTranslator:translatorMock userDefaults:userDefaultsMock];
	NSArray *targetLanguages = [model lastUsedTargetLanguagesNames];
	
	GHAssertEquals([targetLanguages count], (NSUInteger)1, @"size must be 1");
	GHAssertTrue([targetLanguages containsObject:[africans name]], @"english is not present");
}


@end
