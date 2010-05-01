//
//  BFHTTPInvoker.m
//  Babelfish
//
//  Created by Filip Krikava on 4/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFDefaultHTTPInvoker.h"

@implementation BFDefaultHTTPInvoker

- (NSData *) syncInvokeRequest:(NSURLRequest *)request returningResponse:(NSURLResponse **)response error:(NSError **)error {
	NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: response error: error];

	return data;
}


@end
