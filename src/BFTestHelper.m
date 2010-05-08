//
//  TestHelper.m
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <OCMock/OCMock.h>

#import "BFTestHelper.h"
#import "BFTranslator.h"
#import "BFLanguage.h"

BFLanguage* autoDetect;
BFLanguage* africans;
BFLanguage* english;
BFLanguage* french;

void BFTestHelperInitialize() {
	autoDetect = [[BFLanguage alloc] initWithCode:@"" name:@"Auto" imagePath:@""];
	africans = [[BFLanguage alloc] initWithCode:@"af" name:@"Africans" imagePath:@""];
	english = [[BFLanguage alloc] initWithCode:@"en" name:@"English" imagePath:@""];
	french = [[BFLanguage alloc] initWithCode:@"fr" name:@"French" imagePath:@""]; 
}

void BFTestHelperStubBasicTranslatorMethods(id mock) {
	[[[mock stub] andReturn:africans] languageByName:[africans name]];
	[[[mock stub] andReturn:english] languageByName:[english name]];
	[[[mock stub] andReturn:french] languageByName:[french name]];
	[[[mock stub] andReturn:autoDetect] autoDetectTargetLanguage];
}