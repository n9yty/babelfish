//
//  BFTranslationWindowModel.m
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFTranslationWindowModel.h"
#import "BFStringConstants.h"
#import "BFDefines.h"

@implementation BFTranslationWindowModel

@synthesize originalText;
@synthesize translation;
@synthesize translator;
@synthesize selectedSourceLanguage;
@synthesize selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator userDefaults:(NSUserDefaults *)aUserDefaults {
	BFAssert(aTranslator, @"translator must not be nil");
	BFAssert(aUserDefaults, @"userDefaults must not be nil");
	
	if (![super init]) {
		return nil;
	}
	
	translator = [aTranslator retain];
	userDefaults = [aUserDefaults retain];
	
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
	
    [super dealloc];
}

- (NSArray *) lastUsedLanguagesForKey:(NSString *)aKey {
	BFAssert(aKey, @"key must not be nil");

	NSArray *array = [userDefaults arrayForKey:aKey];
	if (isEmpty(array)) {
		return [NSArray array];
	}
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[array count]];
	for (NSString *name in array) {
		BFLanguage *lang = [translator languageByName:name];
		
		// TODO: detect somebody was messing with preferences
		BFAssert(lang, @"Unknown language name: %@", name);
		[result addObject:lang];
	}
	
	return [NSArray arrayWithArray:result];	
}

- (NSArray *) lastUsedSourceLanguages {
	return [self lastUsedLanguagesForKey:BFLastUsedSourceLanguagesKey];
}

- (NSArray *) lastUsedTargetLanguages {
	return [self lastUsedLanguagesForKey:BFLastUsedTargetLanguagesKey];
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
