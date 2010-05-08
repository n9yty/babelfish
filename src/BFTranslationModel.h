//
//  BFTranslationWindowModel.h
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BFTranslator.h"

@class BFTranslateTextOperation;
@class BFLanguage;
@class BFTranslationTask;

@interface BFTranslationModel : NSObject {	
	@private
	NSObject<BFTranslator>* translator;
	NSOperationQueue *operationQueue;	
	NSUserDefaults* userDefaults;
}

@property (readonly) NSArray *languages;
@property (readonly) BFLanguage *autoDetectTargetLanguage;

- (id) initWithTranslator:(NSObject<BFTranslator> *) aTranslator userDefaults:(NSUserDefaults *)aUserDefaults;

- (void) translate:(BFTranslationTask *) aTask andCall:(SEL) aSelector onObject:(id) anObject;
- (BFLanguage*) languageByName:(NSString *)name;

- (NSArray *) lastUsedSourceLanguagesNames;
- (NSArray *) lastUsedTargetLanguagesNames;

- (void) setLastUsedSourceLanguage:(BFLanguage *)aLanguage;
- (void) setLastUsedTargetLanguage:(BFLanguage *)aLanguage;

@end
