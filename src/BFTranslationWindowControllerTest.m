//
//  BFTranslationWindowControllerTest.m
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

#import "BFLanguage.h"
#import "BFUserDefaults.h"
#import "BFTranslationWindowController.h"
#import "BFTranslationWindowModel.h"

@interface BFTranslationWindowControllerTest : GHTestCase {
	id userDefaultsMock;
	id translatorMock;
	id modelMock;
}

@end

static BFLanguage *autoDetect;
static BFLanguage *africans;
static BFLanguage *english;
static BFLanguage *french;

// TODO: extract similarities
@implementation BFTranslationWindowControllerTest

// -- set up / tear down code

- (void)setUpClass	{
	autoDetect = [[BFLanguage alloc] initWithCode:@"" name:@"Auto" imagePath:@""];
	africans = [[BFLanguage alloc] initWithCode:@"af" name:@"Africans" imagePath:@""];
	english = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];
	french = [[BFLanguage alloc] initWithCode:@"fr" name:@"French" imagePath:@""]; 
}

-(void)setUp {
	userDefaultsMock = [[OCMockObject mockForClass:[BFUserDefaults class]] retain];
	translatorMock = [[OCMockObject mockForProtocol:@protocol(BFTranslator)] retain];
	modelMock = [[OCMockObject niceMockForClass:[BFTranslationWindowModel class]] retain];
	
	[[[translatorMock stub] andReturn:africans] languageByName:[africans name]];
	[[[translatorMock stub] andReturn:english] languageByName:[english name]];
	[[[translatorMock stub] andReturn:french] languageByName:[french name]];
	
	[[[translatorMock stub] andReturn:autoDetect] autoDetectTargetLanguage];

	[[[modelMock stub] andReturn:translatorMock] translator];
}

-(void)tearDown {
	[userDefaultsMock release];
	userDefaultsMock = nil;
	
	[translatorMock release];
	translatorMock = nil;

	[modelMock release];
	translatorMock = nil;
}


- (void) testSourceLanguages {
	// prepare mocks	
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedSourceLanguagesNames];

	[[[translatorMock stub] andReturn:[NSArray arrayWithObjects:africans, french, english, nil]] languages];

	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock userDefaults:userDefaultsMock];
	
	NSArray *source = [controller sourceLanguagesMenu];

	GHAssertEquals([source count], (NSUInteger)3+1+1+1, @"invalid count of source items"); 
	GHAssertEquals([source objectAtIndex:0], autoDetect, @"1. item must be auto-detect");
	GHAssertTrue([[source objectAtIndex:1] isSeparatorItem], @"2. item must be separator");
	GHAssertEquals([source objectAtIndex:2], english, @"3. item must be english");
	GHAssertEquals([source objectAtIndex:3], french, @"4. item must be french");
	GHAssertTrue([[source objectAtIndex:4] isSeparatorItem], @"5. item must be separator");
	GHAssertEquals([source objectAtIndex:5], africans, @"6. item must be africans");
}

- (void) testTargetLanguages {
	// prepare mocks	
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedTargetLanguagesNames];
	
	[[[translatorMock stub] andReturn:[NSArray arrayWithObjects:africans, french, english, nil]] languages];
	
	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock userDefaults:userDefaultsMock];
	
	NSArray *target = [controller targetLanguagesMenu];
	
	GHAssertEquals([target count], (NSUInteger)3+1, @"invalid count of source items"); 
	GHAssertEquals([target objectAtIndex:0], english, @"1. item must be english");
	GHAssertEquals([target objectAtIndex:1], french, @"2. item must be french");
	GHAssertTrue([[target objectAtIndex:2] isSeparatorItem], @"3. item must be separator");
	GHAssertEquals([target objectAtIndex:3], africans, @"4. item must be africans");
}

@end
