//
//  BFUserDefaults.h
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BFLanguage;

@interface BFUserDefaults : NSObject {

	@private
	NSUserDefaults* userDefaults;
	
}

- (id) initWithUserDefaults:(NSUserDefaults *)aUserDefaults;

- (NSArray *) lastUsedSourceLanguagesNames;
- (NSArray *) lastUsedTargetLanguagesNames;

- (void) setLastUsedSourceLanguage:(BFLanguage *)aLanguage;
- (void) setLastUsedTargetLanguage:(BFLanguage *)aLanguage;


@end
