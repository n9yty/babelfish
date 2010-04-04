//
//  AppController.m
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "RatedLanguage.h"
#import "LanguageManager.h"
#import "TranslationWindowController.h"
#import "Translator.h"
#import "GoogleTranslator.h"
#import "BFTranslationWindowModel.h"

#import "version.h"

@implementation AppController

- (id)init {
	if (![super init]) {
		return nil;
	}
	
#ifndef NDEBUG
	NSLog(@"Initializing %@ build number %@", [AppController class], [NSNumber numberWithInt:BUILD_NUMBER]);
#endif
	
	windows = [[NSMutableArray alloc] init];
	translator = [[GoogleTranslator alloc] init];
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [AppController class]);
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
	for (Language *l in languages) {
		int r =  [[l name] isEqualToString:@"French"] ? 200 : 1;
		RatedLanguage *rl = [RatedLanguage ratedLanguage:l tag:tag++ rating:r];
		[array addObject:rl];
	}
	
	return array;
}

- (void) newTranslationWindow {
	NSArray *sourceLanguages = [self fakeRating:[[LanguageManager languageManager] allLanguages]];
	NSArray *targetLanguages = [self fakeRating:[[LanguageManager languageManager] allLanguages]];
	
	BFTranslationWindowModel *model = [[[BFTranslationWindowModel alloc] initWithTranslator:translator sourceLanguages:sourceLanguages targetLanguages:targetLanguages] autorelease];
	
	TranslationWindowController *window = [[TranslationWindowController alloc] initWithModel:model];
	[window showWindow:nil];
}

- (IBAction) newTranslationWindow:(id)aSender {
	[self newTranslationWindow];
}


@end
