//
//  BFTranslationTask.m
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFTranslationTask.h"
#import "BFLanguage.h"
#import "BFDefines.h"

@implementation BFTranslationTask

@synthesize originalText;
@synthesize sourceLanguage;
@synthesize targetLanguage;

- (id) initWithOriginalText:(NSString*) anOriginalText sourceLanguage:(BFLanguage*) aSourceLangauge targetLanguage:(BFLanguage*) aTargetLanguage {
	BFAssert(anOriginalText, @"original text must not be nil");
	BFAssert(aSourceLangauge, @"original text must not be nil");
	BFAssert(aTargetLanguage, @"original text must not be nil");

	if (![super init]) {
		return nil;
	}
	
	originalText = [anOriginalText retain];
	sourceLanguage = [aSourceLangauge retain];
	targetLanguage = [aTargetLanguage retain];
	
	return self;
}

- (void) dealloc {
	[originalText release];
	[sourceLanguage release];
	[targetLanguage release];
	
	[super dealloc];
}

@end
