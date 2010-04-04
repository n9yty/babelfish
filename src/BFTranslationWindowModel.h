//
//  BFTranslationWindowModel.h
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Translator.h"
#import "RatedLanguage.h"

@interface BFTranslationWindowModel : NSObject {
	NSObject<Translator>* translator;
	
	NSArray* sourceLanguages;
	NSArray* targetLanguages;
	
	NSString* originalText;
	NSString* translation;
	
	RatedLanguage* selectedSourceLanguage;
	RatedLanguage* selectedTargetLanguage;
}

@property (readonly) NSObject<Translator>* translator;
@property (readonly) NSArray* sourceLanguages;
@property (readonly) NSArray* targetLanguages;
@property (copy) NSString* originalText;
@property (copy) NSString* translation;
@property (retain) RatedLanguage* selectedSourceLanguage;
@property (retain) RatedLanguage* selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<Translator> *)aTranslator sourceLanguages:(NSArray *)theSourceLanguages targetLanguages:(NSArray *)theTargetLanguages;

@end
