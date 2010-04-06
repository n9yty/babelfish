//
//  AppController.h
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BFTranslator.h"

@class BFLanguage;

@interface BFAppController : NSObject {

	@private
	NSObject<BFTranslator> *translator;
	
	NSArray *sourceLanguages;
	NSArray *targetLanguages;
}

- (void) newTransaltionWindowFromSericeCall:(NSPasteboard *)aPboard userData:(NSString *)aUserData error:(NSString **)anError;
- (void) newTranslationWindowToTranslateText:(NSString *)anOriginaltext from:(BFLanguage *)aSourceLang to:(BFLanguage *)aTargetLang;
- (void) newTranslationWindow;

- (NSDictionary *) loadLanguages:(NSError **)anError;
- (void) loadRating:(NSArray *)theLanguages source:(NSString *)aSource error:(NSError **)anError;


- (IBAction) newTranslationWindow:(id)aSender;

@end
