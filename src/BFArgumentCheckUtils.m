//
//  BFArgumentCheckUtils.m
//  Babelfish
//
//  Created by Filip Krikava on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFArgumentCheckUtils.h"
#import "BFDefines.h"

@implementation BFArgumentCheckUtils

@synthesize expectedArray;

+ (id)checkExpectedArray:(NSArray *)anArray {
	BFArgumentCheckUtils *utils = [[BFArgumentCheckUtils alloc] init];
	
	BFAssert(anArray, @"array must not be nil");

	[utils setExpectedArray:anArray];
	
	return utils;
}

- (void) dealloc {
	[expectedArray dealloc];
	
	[super dealloc];
}

- (BOOL) checkArray:(NSArray *)anArray { 
	BFAssert(expectedArray, @"extected array must not be nil");
	BFAssert(anArray, @"array to check must not be nil");
	
	for (id e in expectedArray) {
		if (![anArray containsObject:e]) {
			return NO;
		}
	}
	
	return YES;	
}

@end
