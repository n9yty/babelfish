//
//  BFUserDefaultsTest.m
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <GHUnit/GHUnit.h>
#import <OCMock/OCMock.h>

#import "BFLanguage.h"
#import "BFUserDefaults.h"
#import "BFStringConstants.h"
#import "BFArgumentCheckUtils.h"

@interface BFUserDefaultsTest: GHTestCase {
	id userDefaultsMock;
}

@end

@implementation BFUserDefaultsTest

static BFLanguage *africans;
static BFLanguage *english;
static BFLanguage *french;

// -- set up / tear down code

- (void)setUpClass {
	africans = [[BFLanguage alloc] initWithCode:@"af" name:@"Africans" imagePath:@""];
	english = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];
	french = [[BFLanguage alloc] initWithCode:@"fr" name:@"French" imagePath:@""]; 
}

-(void)setUp {
	userDefaultsMock = [[OCMockObject mockForClass:[NSUserDefaults class]] retain];
}

-(void)tearDown {
	[userDefaultsMock release];
	userDefaultsMock = nil;
}

- (void)testUserPreferencesLastUsedSourceLanguages {
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] arrayForKey:BFLastUsedSourceLanguagesKey];
	[[[userDefaultsMock stub] andReturn:[NSArray arrayWithObject:[africans name]]] arrayForKey:BFLastUsedTargetLanguagesKey];
	
	BFUserDefaults* defaults = [[BFUserDefaults alloc] initWithUserDefaults:userDefaultsMock];
	NSArray *sourceLanguages = [defaults lastUsedSourceLanguagesNames];
	NSArray *targetLanguages = [defaults lastUsedTargetLanguagesNames];
	
	// verify
	GHAssertEquals([sourceLanguages count], (NSUInteger)2, @"size must be 2");
	GHAssertTrue([sourceLanguages containsObject:[english name]], @"english is not present");
	GHAssertTrue([sourceLanguages containsObject:[french name]], @"french is not present");
	
	GHAssertEquals([targetLanguages count], (NSUInteger)1, @"size must be 1");
	GHAssertTrue([targetLanguages containsObject:[africans name]], @"english is not present");
}

@end
