//
//  LanguageManager.h
//  Babelfish
//
//  Created by Filip Krikava on 11/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define IMAGE_TYPE	@"png"
#define CODE_KEY	@"Code"
#define NAME_KEY	@"Name"
#define FLAGS_DIR	@"Flags"

@interface Language : NSObject {
	
	@private
	NSString *_code;
	NSString *_name;
	NSString *_imagePath;
	NSImage *_image;	
}

- (id) initWithCode:(NSString *)code name:(NSString *)name imagePath:(NSString *)imagePath;

- (NSString *)code;
- (NSString *)name;
- (NSImage *)image;

@end

@interface LanguageManager : NSObject {
	@private
	NSDictionary *allLanguages;
}

+ (LanguageManager *) languageManager;

- (Language *)languageByCode:(NSString *)code;
- (int)count;

@end
