//
//  Language+Rating.m
//  Babelfish
//
//  Created by Filip Krikava on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BFLanguage.h"
#import "BFRatedLanguage.h"


@implementation BFRatedLanguage 

@synthesize tag;
@synthesize rating;

- (id)initWithLanguage:(BFLanguage*)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating {
	if (![super initWithCode:[aLanguage code] name:[aLanguage name] imagePath:[aLanguage imagePath]]) {
		return nil;
	}
	
	tag = aTag;
	rating = aRating;
	
	return self;
}

+ (BFRatedLanguage *) ratedLanguage:(BFLanguage *)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating {
	BFRatedLanguage *rl = [[BFRatedLanguage alloc] initWithLanguage:aLanguage tag:aTag rating:aRating];
	
	return [rl autorelease];
}

- (void)dealloc {
	// TODO remove
	[super dealloc];
}

@end
