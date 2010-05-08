//
//  AppController.h
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BFTranslator.h"
#import "BFHTTPInvoker.h"

@class BFLanguage;
@class BFUserDefaults;

@interface BFAppController : NSObject {

	@private
	NSObject<BFTranslator> *translator;
	NSObject<BFHTTPInvoker> *httpInvoker;
	
	BFUserDefaults* userDefaults;
	
	NSArray *sourceLanguages;
	NSArray *targetLanguages;
}

- (void) newTransaltionWindowFromSericeCall:(NSPasteboard *)aPboard userData:(NSString *)aUserData error:(NSString **)anError;
- (void) newTranslationWindowToTranslateText:(NSString *)anOriginaltext from:(BFLanguage *)aSourceLang to:(BFLanguage *)aTargetLang;
- (void) newTranslationWindow;

- (IBAction) newTranslationWindow:(id)aSender;

@end
