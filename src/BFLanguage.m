//
//  Language.m
//  Babelfish
//
//  Created by Filip Krikava on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFLanguage.h"

@implementation BFLanguage

@synthesize code;
@synthesize name;
@synthesize imagePath;
@dynamic image;

- (id) initWithCode:(NSString *)aCode name:(NSString *)aName imagePath:(NSString *)anImagePath {
	if (![super init]) {
		return nil;
	}
	
	code = [aCode retain];
	name = [aName retain];
	imagePath = [anImagePath retain];
	
	return self;
}

- (void)dealloc {
	[code release];
	[name release];
	[imagePath release];
	[image release];
	
	[super dealloc];
}

- (NSImage *)image {
	if (image == nil) {
		image = [[NSImage alloc] initWithContentsOfFile:imagePath];
		
		// TODO: extract into a constant
		[image setSize: NSMakeSize(20, 20)];
	}
	
	return image;
}

- (NSString *)description {
	return name;
}

- (id) copyWithZone:(NSZone *)zone {
	BFLanguage *clone = [[BFLanguage allocWithZone:zone] initWithCode:code name:name imagePath:imagePath];
	return clone;
}

- (BOOL)isEqual:(id)anObject {
	if (anObject == self) {
        return YES;
	}
    if (!anObject || ![anObject isKindOfClass:[self class]]) {
        return NO;
	}
	else {
		BFLanguage *other = (BFLanguage *)anObject;
		if (![name isEqualToString: [other name]]) {
			return NO;
		} 
		return YES;
	}
}

- (NSUInteger)hash {
	NSUInteger hash = 1;
    hash += 13 *[name hash];
	
	return hash;
}

@end
