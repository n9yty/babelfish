//
//  BFTranslationWindowModel.h
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BFTranslator.h"
#import "BFLanguage.h"

@interface BFTranslationWindowModel : NSObject {	
	@private
	NSObject<BFTranslator>* translator;
	NSUserDefaults *userDefaults;
	
	NSString* originalText;
	NSString* translation;
	
	BFLanguage* selectedSourceLanguage;
	BFLanguage* selectedTargetLanguage;
}

@property (readonly) NSObject<BFTranslator>* translator;
@property (copy) NSString* originalText;
@property (copy) NSString* translation;
@property (retain) BFLanguage* selectedSourceLanguage;
@property (retain) BFLanguage* selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator userDefaults:(NSUserDefaults *)aUserDefaults;

- (NSArray *) lastUsedSourceLanguages;
- (NSArray *) lastUsedTargetLanguages;

- (void) setLastUsedSourceLanguage:(BFLanguage *)aLanguage;
- (void) setLastUsedTargetLanguage:(BFLanguage *)aLanguage;

@end
