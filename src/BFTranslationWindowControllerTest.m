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
#import "BFTestHelper.h"
#import "BFTranslationWindowController.h"
#import "BFTranslationModel.h"

@interface BFTranslationWindowControllerTest : GHTestCase {
	id modelMock;
}

@end

@implementation BFTranslationWindowControllerTest

// -- set up / tear down code

- (void)setUpClass	{
	BFTestHelperInitialize();
}

-(void)setUp {
	modelMock = [[OCMockObject niceMockForClass:[BFTranslationModel class]] retain];
	
	BFTestHelperStubBasicTranslatorMethods(modelMock);
}

-(void)tearDown {
	[modelMock release];
}

- (void)testInitializationDefaults {
	// prepare mocks
	[[[modelMock stub] andReturn:nil] lastUsedSourceLanguagesNames];
	[[[modelMock stub] andReturn:nil] lastUsedTargetLanguagesNames];
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// test
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	
	GHAssertEquals(autoDetect, [controller sourceLanguage], @"invalid source language selected");	
	GHAssertEquals(africans, [controller targetLanguage], @"invalid target language selected");	
}

- (void)testInitializationDefaultsWithUserDefaults {
	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedSourceLanguagesNames];
	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:[french name], [english name], nil]] lastUsedTargetLanguagesNames];
	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	
	GHAssertEquals(english, [controller sourceLanguage], @"invalid source language selected");	
	GHAssertEquals(french, [controller targetLanguage], @"invalid target language selected");	
}

- (void)testSwap {	
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setSourceLanguage:english];
	[controller setTargetLanguage:french];
	
	[controller swapLanguages];
	
	GHAssertEquals(french, [controller sourceLanguage],@"invalid source languge after swap");
	GHAssertEquals(english, [controller targetLanguage],@"invalid target languge after swap");
}

- (void)testSwapAutoDetectLanguage {
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
		
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setSourceLanguage:autoDetect];
	[controller setTargetLanguage:french];
	
	[controller swapLanguages];
	
	GHAssertEquals(autoDetect, [controller sourceLanguage],@"invalid source languge after swap");
	GHAssertEquals(french, [controller targetLanguage],@"invalid target languge after swap");
}

- (void) testSourceLanguages {
	// prepare mocks	
	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedSourceLanguagesNames];

	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:africans, french, english, nil]] languages];

	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	
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
	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:[english name], [french name], nil]] lastUsedTargetLanguagesNames];
	
	[[[modelMock stub] andReturn:[NSArray arrayWithObjects:africans, french, english, nil]] languages];
	
	
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	
	NSArray *target = [controller targetLanguagesMenu];
	
	GHAssertEquals([target count], (NSUInteger)3+1, @"invalid count of source items"); 
	GHAssertEquals([target objectAtIndex:0], english, @"1. item must be english");
	GHAssertEquals([target objectAtIndex:1], french, @"2. item must be french");
	GHAssertTrue([[target objectAtIndex:2] isSeparatorItem], @"3. item must be separator");
	GHAssertEquals([target objectAtIndex:3], africans, @"4. item must be africans");
}

- (void) testSourceLanguageViewSync {
	// prepare mocks
	[[[modelMock stub] andReturn:nil] lastUsedSourceLanguagesNames];
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// set up mock for the NSPopupMenu
	id menuMock = [OCMockObject mockForClass:[NSPopUpButton class]];
	[[[menuMock stub] andReturn:nil] selectedItem];
	[[menuMock expect] selectItemWithTag:[french hash]];
		
	// test
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setValue:menuMock forKey:@"sourceLanguagePopup"];
	[controller setSourceLanguage:french];

	[menuMock verify];
}

- (void) testTargetLanguageViewSync {
	// prepare mocks
	[[[modelMock stub] andReturn:nil] lastUsedTargetLanguagesNames];
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// set up mock for the NSPopupMenu
	id menuMock = [OCMockObject mockForClass:[NSPopUpButton class]];
	[[[menuMock stub] andReturn:nil] selectedItem];
	[[menuMock expect] selectItemWithTag:[french hash]];
	
	// test
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setValue:menuMock forKey:@"targetLanguagePopup"];
	[controller setTargetLanguage:french];
	
	[menuMock verify];
}

- (void) testSuccessfulTranslate {
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	NSString* originalText = @"Hello World";
		
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[[modelMock expect] translate:[OCMArg checkWithBlock:
	 ^BOOL(id task) {
		return [originalText isEqual:[task originalText]] 
		&& [task sourceLanguage] == english
		&& [task targetLanguage] == french;
	}] andCall:@selector(taskTranslated:translation:error:) onObject:controller];
	[controller setSourceLanguage:english];
	[controller setTargetLanguage:french];
	[controller setOriginalText:originalText];
	[controller translate];
	
	[modelMock verify];
}

- (void) testTranslateButtonDisabledWhenNoTextToTranslate {
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// set up mock for the NSPopupMenu
	id menuMock = [OCMockObject mockForClass:[NSButton class]];
	[[menuMock expect] setEnabled:NO];
	
	// test
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setValue:menuMock forKey:@"translateButton"];
	[controller setOriginalText:@""];
	
	[menuMock verify];	
}

- (void) testTranslateButtonEnabledWhenTextToTranslate {
	[[[modelMock stub] andReturn:[NSArray arrayWithObject:africans]] languages];
	
	// set up mock for the NSPopupMenu
	id menuMock = [OCMockObject mockForClass:[NSButton class]];
	[[menuMock expect] setEnabled:YES];
	
	// test
	BFTranslationWindowController* controller = [[BFTranslationWindowController alloc] initWithModel:modelMock];
	[controller setValue:menuMock forKey:@"translateButton"];
	[controller setOriginalText:@"Some text"];
	
	[menuMock verify];	
}

@end
