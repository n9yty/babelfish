//
//  Language.h
//  Babelfish
//
//  Created by Filip Krikava on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BFLanguage : NSObject <NSCopying> {
	
@private
	NSString *code;
	NSString *name;
	NSString *imagePath;
	NSImage *image;	
}

- (id) initWithCode:(NSString *)aCode name:(NSString *)aName imagePath:(NSString *)anImagePath;

@property (readonly) NSString *code;
@property (readonly) NSString *imagePath;
@property (readonly) NSString *name;
@property (readonly) NSImage *image;

@end