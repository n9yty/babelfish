//
//  BFStringConstants.m
//  Babelfish
//
//  Created by Filip Krikava on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFConstants.h"

NSString *const BFLastUsedSourceLanguagesKey = @"BFLastUsedSourceLanguagesKey";
NSString *const BFLastUsedTargetLanguagesKey = @"BFLastUsedTargetLanguagesKey";

NSUInteger const BFLastUsedLanguageCount = 5;

static NSSortDescriptor* BFNameSortDescriptor;

@implementation BFConstants

+ (void) initialize {
	BFNameSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
}

+ (NSSortDescriptor *) BFNameSortDescriptor {
	return BFNameSortDescriptor;
}

@end

