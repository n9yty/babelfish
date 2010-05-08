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

@class BFTranslateTextOperation;
@class BFUserDefaults;

@interface BFTranslationWindowModel : NSObject {	
	@private
	NSObject<BFTranslator>* translator;
	BFUserDefaults *userDefaults;
	
	NSString* originalText;
	NSString* translation;
	
	BFLanguage* selectedSourceLanguage;
	BFLanguage* selectedTargetLanguage;
	
	// the last translation operation
	// TODO: is it last?
	BFTranslateTextOperation* lastTranslation;
	NSTimer *translateTimer;	
	NSOperationQueue *operationQueue;	
}

@property (readonly) NSObject<BFTranslator>* translator;
@property (copy) NSString* originalText;
@property (copy) NSString* translation;
@property (retain) BFLanguage* selectedSourceLanguage;
@property (retain) BFLanguage* selectedTargetLanguage;

- (id)initWithTranslator:(NSObject<BFTranslator> *)aTranslator userDefaults:(BFUserDefaults *)aUserDefaults;

- (void) swapLanguages;

@end
