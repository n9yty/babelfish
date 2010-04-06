//
//  AppController.h
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BFTranslator.h"

@interface BFAppController : NSObject {

	@private
	NSObject<BFTranslator> *translator;
	NSMutableArray *windows;
}

- (NSArray *) fakeRating:(NSArray *)languages;
//- (void)openWindow:(NSPasteboard *)aPboard userData:(NSString *)aUserData error:(NSString **)anError;

- (void) newTranslationWindow;
- (IBAction) newTranslationWindow:(id)aSender;

@end
