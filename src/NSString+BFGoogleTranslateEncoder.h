//
//  NSString+BFGoogleTranslateEncoder.h
//  Babelfish
//
//  Created by Filip Krikava on 5/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (BFGoogleTranslateEncoderAdditions)

- (NSString *) stringByEncodingForGoogleTranslate;

- (NSString *) stringByDecodingFromGoogleTranslate;

@end
