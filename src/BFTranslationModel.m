//
//  BFTranslationWindowModel.m
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFTranslationModel.h"
#import "BFTranslationTask.h"
#import "BFTranslateTextOperation.h"
#import "BFConstants.h"
#import "BFDefines.h"

@implementation BFTranslationModel

@dynamic languages;
@dynamic autoDetectTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator userDefaults:(NSUserDefaults *)aUserDefaults {
	BFAssert(aTranslator, @"translator must not be nil");
	BFAssert(aTranslator, @"user defaults must not be nil");
	
	if (![super init]) {
		return nil;
	}
	
	operationQueue = [[NSOperationQueue alloc] init];
	[operationQueue setMaxConcurrentOperationCount:1];
		
	translator = [aTranslator retain];
	userDefaults = [aUserDefaults retain];
	
	return self;
}

- (void) dealloc
{
    [translator release];
	[userDefaults release];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[operationQueue cancelAllOperations];
	[operationQueue release];	

    [super dealloc];
}

- (void) translate:(BFTranslationTask *) aTask andCall:(SEL) aSelector onObject:(id) anObject {
	// cancel all pending translation (should be at max one)
	[operationQueue cancelAllOperations];
		
	// create a new translation operation
	BFTranslateTextOperation *operation = [[BFTranslateTextOperation alloc] initWithTask:aTask translator:translator selector:aSelector onObject:anObject];
	
	// enqueue
	[operationQueue addOperation:operation];	
}

- (NSArray *) languages {
	return [translator languages];
}

- (BFLanguage*) autoDetectTargetLanguage {
	return [translator autoDetectTargetLanguage];
}

- (BFLanguage*) languageByName:(NSString *)name {
	return [translator languageByName:name];
}

- (NSArray *) lastUsedLanguagesNamesForKey:(NSString *)aKey {
	BFAssert(aKey, @"key must not be nil");
	
	NSArray *array = [userDefaults arrayForKey:aKey];
	if (isEmpty(array)) {
		return nil;
	}
	
	return array;	
}

- (NSArray *) lastUsedSourceLanguagesNames {
	return [self lastUsedLanguagesNamesForKey:BFLastUsedSourceLanguagesKey];
}

- (NSArray *) lastUsedTargetLanguagesNames {
	return [self lastUsedLanguagesNamesForKey:BFLastUsedTargetLanguagesKey];
}

- (void) setLastUsedLanguage:(BFLanguage *)aLanguage forKey:(NSString *)aKey {
	BFAssert(aLanguage, @"language must not be nil");
	BFAssert(aKey, @"key must not be nil");
	
	NSMutableArray *array = [NSMutableArray arrayWithArray:[userDefaults arrayForKey:aKey]];
	
	if (isEmpty(array)) {
		[array addObject:[aLanguage name]];
	} else {
		if (![[array objectAtIndex:0] isEqual:[aLanguage name]]) {
			[array insertObject:[aLanguage name] atIndex:0];
		}
		
		if ([array count] > BFLastUsedLanguageCount) {
			[array removeObjectsInRange:NSMakeRange(BFLastUsedLanguageCount, [array count] - BFLastUsedLanguageCount)];
		}
		BFAssert([array count] <= BFLastUsedLanguageCount, @"maximum %d languages", BFLastUsedLanguageCount);
	}
	
	// save it
	[userDefaults setObject:array forKey:aKey];
}

- (void) setLastUsedSourceLanguage:(BFLanguage *)aLanguage {
	BFAssert(aLanguage, @"language must not be nil");
	[self setLastUsedLanguage:aLanguage forKey:BFLastUsedSourceLanguagesKey]; 
}

- (void) setLastUsedTargetLanguage:(BFLanguage *)aLanguage {
	BFAssert(aLanguage, @"language must not be nil");
	[self setLastUsedLanguage:aLanguage forKey:BFLastUsedTargetLanguagesKey]; 
}

@end
