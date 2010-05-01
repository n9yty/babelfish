//
//  BFHTTPInvoker.h
//  Babelfish
//
//  Created by Filip Krikava on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BFHTTPInvoker : NSObject

- (NSData *) syncInvokeRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error;  

@end
