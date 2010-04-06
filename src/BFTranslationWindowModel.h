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
	NSObject<BFTranslator>* translator;
	
	NSArray* sourceLanguages;
	NSArray* targetLanguages;
	
	NSString* originalText;
	NSString* translation;
	
	BFLanguage* selectedSourceLanguage;
	BFLanguage* selectedTargetLanguage;
}

@property (readonly) NSObject<BFTranslator>* translator;
@property (readonly) NSArray* sourceLanguages;
@property (readonly) NSArray* targetLanguages;
@property (copy) NSString* originalText;
@property (copy) NSString* translation;
@property (retain) BFLanguage* selectedSourceLanguage;
@property (retain) BFLanguage* selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator sourceLanguages:(NSArray *)theSourceLanguages targetLanguages:(NSArray *)theTargetLanguages;

@end
