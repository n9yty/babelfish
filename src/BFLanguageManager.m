//
//  LanguageManager.m
//  Babelfish
//
//  Created by Filip Krikava on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BFLanguageManager.h"
#import "BFLanguage.h"

@implementation BFLanguageManager

static BFLanguageManager *languageManager = nil; 

+ (BFLanguageManager *) languageManager {
	if (languageManager == nil) {
		languageManager = [[super allocWithZone:nil] init];
	}
	
	return languageManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self languageManager] retain];
}

- (id)init {
#ifndef NDEBUG
	NSLog(@"Initializing language manager");
#endif
	
	if (![super init]) {
		return nil;
	}
	
	
	return self;
}

- (void)dealloc {
	// TODO: dealloc all languages?
	[allLanguages dealloc];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (BFLanguage *)languageByCode:(NSString *)code {
#ifndef NDEBUG
	NSLog(@"languageByCode:\"%@\"", code);
#endif
	
	// TODO: check arguments
	
	BFLanguage *lang = [allLanguages objectForKey:code];
	return lang;
}

- (NSArray *) allLanguages {
	return [allLanguages allValues];
}

- (int)count {
#ifndef NDEBUG
	NSLog(@"count");
#endif

	return [allLanguages count];
}

@end
