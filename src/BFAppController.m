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

#import "version.h"

@implementation BFAppController

#define BFLanguageCodeKey @"Code"
#define BFLanguageNameKey @"Name" 
#define BFLanguageFlagImageFileType @"png"
#define BFLanguageFlagsDir @"Flags"

- (id)init {
	if (![super init]) {
		return nil;
	}
	
#ifndef NDEBUG
	NSLog(@"Initializing %@ build number %@", [BFAppController class], [NSNumber numberWithInt:BUILD_NUMBER]);
#endif
	
	translator = [[BFGoogleTranslator alloc] init];
	return self;
}

- (void)dealloc {
#ifndef NDEBUG
	NSLog(@"Deallocing %@", [BFAppController class]);
#endif

	[sourceLanguages release];
	[targetLanguages release];
	[translator release];
	
	[super dealloc];
}	

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#ifndef NDEBUG
	NSLog(@"Registering self as a service service");
#endif

	NSError *error = nil;
	// load languages
	NSDictionary *allLanguages = [self loadLanguages:&error];
	
	// attach an observer to each language and when the rating changes it will automatically save it to the the .plist
	
	if (error) {
		// TODO: handle error - fail
	}
	
	// TODO: assert the size of languages
#ifndef NDEBUG
	NSLog(@"language manager initialized with %d entries", [allLanguages count]);
#endif
	
	// load source language rating
	error = nil;
	sourceLanguages = [allLanguages allValues];
	[self loadRating:sourceLanguages source:nil error:&error];
	if (error) {
		// TODO: handle error
	}
	
	// load target langauge rating
	error = nil;
	targetLanguages = [allLanguages allValues];
	[self loadRating:targetLanguages source:nil error:&error];
	if (error) {
		// TODO: handle error
	}
	
	// initialize service provider
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

- (NSDictionary *) loadLanguages:(NSError **)anError {
	NSArray *languages = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SupportedLanguages" ofType:@"plist"]];
	
	if (!languages) {
		// TODO: handle error
	}
	
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[languages count]];
		
	for (NSDictionary *dict in languages) {
		NSString *code = [dict objectForKey:BFLanguageCodeKey];
		NSString *name = [dict objectForKey:BFLanguageNameKey];
		BFLanguage *lang = [[BFLanguage alloc] initWithCode:code name:name imagePath:[[NSBundle mainBundle] pathForResource:code ofType:BFLanguageFlagImageFileType inDirectory:BFLanguageFlagsDir]];
		
		if (!lang) {
			// TODO: handle error
		}
		
		[d setObject:lang forKey:code];
	}
	
	return [[NSDictionary dictionaryWithDictionary:d] retain];
}

- (void) loadRating:(NSArray *)theLanguages source:(NSString *)aSource error:(NSError **)anError {
	for (BFLanguage *l in theLanguages) {
		int r =  [[l name] isEqualToString:@"French"] ? 200 : 1;
		[l setRating:r];
	}
}

/**
 * @param aSourceLanguage has to come from the {@code sourceLanguages} array
 * @param aTargetLanguage has to come from the {@code targetLanguages} array
 */
- (void) newTranslationWindowToTranslateText:(NSString *)anOriginalText from:(BFLanguage *)aSourceLanguage to:(BFLanguage *)aTargetLanguage {
	BFTranslationWindowModel *model = [[[BFTranslationWindowModel alloc] initWithTranslator:translator sourceLanguages:sourceLanguages targetLanguages:targetLanguages] autorelease];

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

- (BFLanguage *) findLanguageByCode:(NSString *)code within:(NSArray *)array {
	for (BFLanguage *l in array) {
		if ([code isEqualToString:[l code]]) {
			return l;
		}
	}
			
	return nil;
}

- (void)newTransaltionWindowFromSericeCall:(NSPasteboard *)aPboard userData:(NSString *)aUserData error:(NSString **)anError {
#ifndef NDEBUG
	NSLog(@"newTransaltionWindowFromSericeCall:\"%@\" userData:\"%@\"", aPboard, aUserData);
#endif
	
	BFLanguage *from = nil;
	BFLanguage *to = nil;
	
	if (aUserData != nil) {
		// extract the language pair if exists
		NSArray *languagePair = [aUserData componentsSeparatedByString:@"-"];
		if ([languagePair count] != 2) {
			*anError = NSLocalizedString(@"Error: invalid service description. It should be either empty or contain a language pair as <source_language_code>|<target_language_code> (eg \"en|fr\").", nil);
			return;
		} else {
			from = [self findLanguageByCode:[languagePair objectAtIndex:0] within:sourceLanguages];
			if (!from) {
				*anError = NSLocalizedString(@"Error: from language is not supported.", nil);
				return;
			}
			
			from = [self findLanguageByCode:[languagePair objectAtIndex:1] within:targetLanguages];
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
