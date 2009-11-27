//
//  refreshservices.m
//  Babelfish
//
//  Created by Filip Krikava on 11/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"Refreshing OSX services");
	NSUpdateDynamicServices();
	NSLog(@"OSX services refreshed");
	
    [pool drain];
	
	return 0;
}