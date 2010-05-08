//
//  BFTranslationWindowModel.m
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFTranslationWindowModel.h"
#import "BFConstants.h"
#import "BFUserDefaults.h"
#import "BFDefines.h"

@implementation BFTranslationWindowModel

@synthesize originalText;
@synthesize translation;
@synthesize translator;
@synthesize selectedSourceLanguage;
@synthesize selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator userDefaults:(BFUserDefaults *)aUserDefaults {
	BFAssert(aTranslator, @"translator must not be nil");
	BFAssert(aUserDefaults, @"userDefaults must not be nil");
	
	if (![super init]) {
		return nil;
	}
	
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
		
	
	translator = [aTranslator retain];
	userDefaults = [aUserDefaults retain];
	
	// set the defaults
	
	// set source language
	NSString* languageName = [[userDefaults lastUsedSourceLanguagesNames] objectAtIndex:0];
	BFLanguage *language = languageName ? [translator languageByName:languageName] : nil;
	if (!language) {
		language = [translator autoDetectTargetLanguage];
	}
	BFAssert(language, @"source language has to be set");
	[self setSelectedSourceLanguage:language];
	
	// set target language
	languageName = [[userDefaults lastUsedTargetLanguagesNames] objectAtIndex:0];
	language = languageName ? [translator languageByName:languageName] : nil;
	
	if (!language) {
		// TODO: get language close to the local settings
		language = [[[translator languages] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[BFConstants BFNameSortDescriptor]]] objectAtIndex:0];
	}
	BFAssert(language, @"target language has to be set");
	[self setSelectedTargetLanguage:language];
	
	return self;
}

- (void) dealloc
{
    [translator release];
	[userDefaults release];
    [originalText release];
    [translation release];
	[selectedSourceLanguage release];
	[selectedTargetLanguage release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[operationQueue cancelAllOperations];
	[operationQueue release];	
	[translateTimer release];

    [super dealloc];
}

- (void) swapLanguages {
	BFLanguage* source = selectedSourceLanguage;
	BFLanguage* target = selectedTargetLanguage;
	
	if ([source isEqual:[translator autoDetectTargetLanguage]]) {
		return;
	}

	[self setSelectedSourceLanguage: target];
	[self setSelectedTargetLanguage: source];	
}

- (void) translate {
	
}

@end
