//
//  BFStringConstants.h
//  Babelfish
//
//  Created by Filip Krikava on 5/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


# pragma mark User default keys

extern NSString *const BFLastUsedSourceLanguagesKey;
extern NSString *const BFLastUsedTargetLanguagesKey;

extern NSUInteger const BFLastUsedLanguageCount;

@interface BFConstants : NSObject
{
	NSSortDescriptor* BFNameSortDescriptor;
}

+(void) initialize;
+ (NSSortDescriptor *) BFNameSortDescriptor;

@end
