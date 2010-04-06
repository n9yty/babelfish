//
//  BFTranslationWindowModel.h
//  Babelfish
//
//  Created by Filip Krikava on 3/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BFTranslator.h"
#import "BFRatedLanguage.h"

@interface BFTranslationWindowModel : NSObject {
	NSObject<BFTranslator>* translator;
	
	NSArray* sourceLanguages;
	NSArray* targetLanguages;
	
	NSString* originalText;
	NSString* translation;
	
	BFRatedLanguage* selectedSourceLanguage;
	BFRatedLanguage* selectedTargetLanguage;
}

@property (readonly) NSObject<BFTranslator>* translator;
@property (readonly) NSArray* sourceLanguages;
@property (readonly) NSArray* targetLanguages;
@property (copy) NSString* originalText;
@property (copy) NSString* translation;
@property (retain) BFRatedLanguage* selectedSourceLanguage;
@property (retain) BFRatedLanguage* selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator sourceLanguages:(NSArray *)theSourceLanguages targetLanguages:(NSArray *)theTargetLanguages;

@end
