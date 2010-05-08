//
//  BFUserDefaults.m
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFUserDefaults.h"
#import "BFStringConstants.h"
#import "BFDefines.h"

@implementation BFUserDefaults

- (id) initWithUserDefaults:(NSUserDefaults *)aUserDefaults {
	BFAssert(aUserDefaults, @"user defaults must not be nil");
	
	if (![super init]) {
		return nil;
	}
	
	userDefaults = [aUserDefaults retain];
	
	return self;
}

- (void) dealloc {
	[userDefaults release];
	
	[super dealloc];
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
