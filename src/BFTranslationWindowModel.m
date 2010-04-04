//
//  BFTranslationWindowModel.m
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFTranslationWindowModel.h"

@implementation BFTranslationWindowModel

@synthesize originalText;
@synthesize sourceLanguages;
@synthesize targetLanguages;
@synthesize translation;
@synthesize translator;
@synthesize selectedSourceLanguage;
@synthesize selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<Translator> *)aTranslator sourceLanguages:(NSArray *)theSourceLanguages targetLanguages:(NSArray *)theTargetLanguages{
	if (![super init]) {
		return nil;
	}
	
	translator = [aTranslator retain];
	sourceLanguages = [theSourceLanguages retain];
	targetLanguages = [theTargetLanguages retain];

	return self;
}


- (void) dealloc
{
    [translator release];
	[sourceLanguages release];
	[targetLanguages release];
    [originalText release];
    [translation release];
	[selectedSourceLanguage release];
	[selectedTargetLanguage release];
    [super dealloc];
}

@end
