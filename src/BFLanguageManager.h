//
//  LanguageManager.h
//  Babelfish
//
//  Created by Filip Krikava on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// TODO: change to constants
#define IMAGE_TYPE	@"png"

#define CODE_KEY	@"Code"
#define NAME_KEY	@"Name"
#define FLAGS_DIR	@"Flags"

@class BFLanguage;

@interface BFLanguageManager : NSObject {
	@private
	NSDictionary *allLanguages;
}

+ (BFLanguageManager *) languageManager;

- (BFLanguage *)languageByCode:(NSString *)code;
- (NSArray *) allLanguages;
- (int)count;

@end
