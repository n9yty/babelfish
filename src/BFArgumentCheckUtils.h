//
//  BFArgumentCheckUtils.h
//  Babelfish
//
//  Created by Filip Krikava on 5/5/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BFArgumentCheckUtils : NSObject {
	@private
	NSArray *expectedArray;
}

@property(retain) NSArray *expectedArray;

+ (id)checkExpectedArray:(NSArray *)anArray;

- (BOOL) checkArray:(NSArray *)anArray;

@end
