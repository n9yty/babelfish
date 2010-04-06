//
//  AppController.m
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFAppController.h"
#import "BFRatedLanguage.h"
#import "BFLanguageManager.h"
#import "BFTranslationWindowController.h"
#import "BFTranslator.h"
#import "BFGoogleTranslator.h"
#import "BFTranslationWindowModel.h"

#import "version.h"

@implementation BFAppController

- (id)init {
	if (![super init]) {
		return nil;
	}
	
#ifndef NDEBUG
	NSLog(@"Initializing %@ build number %@", [BFAppController class], [NSNumber numberWithInt:BUILD_NUMBER]);
#endif
	
	windows = [[NSMutableArray alloc] init];
	translator = [[BFGoogleTranslator alloc] init];
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [BFAppController class]);
#endif

	[windows release];
	[translator release];
	
	[super dealloc];
}	

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#ifndef NDEBUG
	NSLog(@"Registering self as a service service");
#endif
	
	[NSApp setServicesProvider:self];
	
	// TODO: condition if there is not going to be a new window
	[self newTranslationWindow];
}

- (void)awakeFromNib {
#ifndef NDEBUG
	NSLog(@"Main Nib2 has been loaded");
#endif
	// TODO: loading preferences goes here	
}

- (NSArray *) fakeRating:(NSArray *)languages {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[languages count]];
	int tag = 0;
	for (BFLanguage *l in languages) {
		int r =  [[l name] isEqualToString:@"French"] ? 200 : 1;
		BFRatedLanguage *rl = [BFRatedLanguage ratedLanguage:l tag:tag++ rating:r];
		[array addObject:rl];
	}
	
	return array;
}

- (void) newTranslationWindow {
	NSArray *sourceLanguages = [self fakeRating:[[BFLanguageManager languageManager] allLanguages]];
	NSArray *targetLanguages = [self fakeRating:[[BFLanguageManager languageManager] allLanguages]];
	
	BFTranslationWindowModel *model = [[[BFTranslationWindowModel alloc] initWithTranslator:translator sourceLanguages:sourceLanguages targetLanguages:targetLanguages] autorelease];
	
	BFTranslationWindowController *window = [[BFTranslationWindowController alloc] initWithModel:model];
	[window showWindow:nil];
}

- (IBAction) newTranslationWindow:(id)aSender {
	[self newTranslationWindow];
}


@end
