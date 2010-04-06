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
	
	NSArray *languages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SupportedLanguages" ofType:@"plist"]];
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[languages count]];
	
	// TODO: if this fails?
	
	for (NSDictionary *dict in languages) {
		NSString *code = [dict objectForKey:CODE_KEY];
		NSString *name = [dict objectForKey:NAME_KEY];
		BFLanguage *lang = [[BFLanguage alloc] initWithCode:code name:name imagePath:[[NSBundle mainBundle] pathForResource:code ofType:IMAGE_TYPE inDirectory:FLAGS_DIR]];
		// TODO: if this fails?
		[d setObject:lang forKey:code];
	}
	
	allLanguages = [[NSDictionary dictionaryWithDictionary:d] retain];

#ifndef NDEBUG
	NSLog(@"language manager initialized with %d entries", [allLanguages count]);
#endif
	
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
