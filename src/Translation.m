//
//  Translation.m
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Translation.h"


@implementation Translation

@synthesize originalText;
@synthesize translatedText;

@synthesize sourceLanguage;
@dynamic targetLanguage;

- (RatedLanguage *) targetLanguage {
	return targetLanguge;
}

- (void) setTargetLanguage:(RatedLanguage *)aLanguage {
	NSLog(@"set: %@", aLanguage);
	[aLanguage retain];
	[targetLanguge release];
	targetLanguge = aLanguage;
}

@end
