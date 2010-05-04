//
//  AppController.m
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFAppController.h"
#import "BFTranslationWindowController.h"
#import "BFTranslator.h"
#import "BFGoogleTranslator.h"
#import "BFTranslationWindowModel.h"
#import "BFDefaultHTTPInvoker.h"
#import "BFDefines.h"

#import "version.h"

@implementation BFAppController

- (id)init {
	BFTrace();
	if (![super init]) {
		return nil;
	}
	
	BFDevLog(@"Initializing %@ build number %@", [BFAppController class], [NSNumber numberWithInt:BUILD_NUMBER]);
	
	httpInvoker = [[BFDefaultHTTPInvoker alloc] init];
	translator = [[BFGoogleTranslator alloc] initWithHTTPInvoker:httpInvoker];
	return self;
}

- (void)dealloc {
	[sourceLanguages release];
	[targetLanguages release];
	[translator release];
	
	[super dealloc];
}	

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {	
	// initialize service provider
	[NSApp setServicesProvider:self];
	
	// TODO: condition if there is not going to be a new window
	[self newTranslationWindow];
}

- (void)awakeFromNib {
	// TODO: loading preferences goes here	
}

/**
 * @param aSourceLanguage has to come from the {@code sourceLanguages} array
 * @param aTargetLanguage has to come from the {@code targetLanguages} array
 */
- (void) newTranslationWindowToTranslateText:(NSString *)anOriginalText from:(BFLanguage *)aSourceLanguage to:(BFLanguage *)aTargetLanguage {
	BFTranslationWindowModel *model = [[[BFTranslationWindowModel alloc] initWithTranslator:translator userDefaults:[NSUserDefaults standardUserDefaults]] autorelease];

	[model setOriginalText:anOriginalText];
	[model setSelectedSourceLanguage:aSourceLanguage];
	[model setSelectedTargetLanguage:aTargetLanguage];
	
	BFTranslationWindowController *window = [[BFTranslationWindowController alloc] initWithModel:model];
	[window showWindow:nil];
}
	 
- (void) newTranslationWindow {
	[self newTranslationWindowToTranslateText:nil from:nil to:nil];
}

- (IBAction) newTranslationWindow:(id)aSender {
	[self newTranslationWindow];
}

- (void)newTransaltionWindowFromSericeCall:(NSPasteboard *)aPboard userData:(NSString *)aUserData error:(NSString **)anError {
	BFDevLog(@"newTransaltionWindowFromSericeCall:\"%@\" userData:\"%@\"", aPboard, aUserData);
	
	BFLanguage *from = nil;
	BFLanguage *to = nil;
	
	if (aUserData != nil) {
		// extract the language pair if exists
		NSArray *languagePair = [aUserData componentsSeparatedByString:@"-"];
		if ([languagePair count] != 2) {
			*anError = NSLocalizedString(@"Error: invalid service description. It should be either empty or contain a language pair as <source_language_code>|<target_language_code> (eg \"en|fr\").", nil);
			return;
		} else {
			from = [translator languageByName:[languagePair objectAtIndex:0]];
			if (!from) {
				*anError = NSLocalizedString(@"Error: from language is not supported.", nil);
				return;
			}
			
			to = [translator languageByName:[languagePair objectAtIndex:1]];
			if (!to) {
				*anError = NSLocalizedString(@"Error: to language is not supported.", nil);
				return;
			}			

			if (from == to) {
				*anError = NSLocalizedString(@"Error: from and to languages are the same. This does not make much sense, does it?", nil);
				return;
			}
		}
	}
	
	// check for string in pasteboard
    NSArray *types = [aPboard types];
    if (![types containsObject:NSStringPboardType]) {
        *anError = NSLocalizedString(@"Error: no string found in the paste board.", nil);
        return;
    }
	
	// get the string - this will return the selected text
    NSString *text = [aPboard stringForType:NSStringPboardType];
	// TODO: check white characters
    if (!text || [text length] == 0) {
        *anError = NSLocalizedString(@"Error: no string found in the paste board.", nil);
        return;
    }
	
	// do the actual transaltion
	[self newTranslationWindowToTranslateText:text from:from to:to];
	
	return;	
}

@end
