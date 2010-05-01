//
//  NSString+URLEncode.m
//  Babelfish
//
//  Created by Filip Krikava on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncode.h"


@implementation NSString (BFURLEncodeAdditions)

- (NSString *)stringByURLEscape {
	CFStringRef escaped = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																  (CFStringRef)self,
																  NULL,
																  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																  kCFStringEncodingUTF8);
	return [(NSString *)escaped autorelease];
}

@end
