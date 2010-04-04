//
//  Language+Rating.m
//  Babelfish
//
//  Created by Filip Krikava on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Language.h"
#import "RatedLanguage.h"


@implementation RatedLanguage 

@synthesize tag;
@synthesize rating;

- (id)initWithLanguage:(Language*)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating {
	if (![super initWithCode:[aLanguage code] name:[aLanguage name] imagePath:[aLanguage imagePath]]) {
		return nil;
	}
	
	tag = aTag;
	rating = aRating;
	
	return self;
}

+ (RatedLanguage *) ratedLanguage:(Language *)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating {
	RatedLanguage *rl = [[RatedLanguage alloc] initWithLanguage:aLanguage tag:aTag rating:aRating];
	
	return [rl autorelease];
}

- (void)dealloc {
	// TODO remove
	[super dealloc];
}

@end
