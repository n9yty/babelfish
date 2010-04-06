//
//  Language+Rating.h
//  Babelfish
//
//  Created by Filip Krikava on 2/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "BFLanguage.h"

@interface BFRatedLanguage : BFLanguage {

	@private
	NSInteger tag;		// FIXME: this is here just because of issue#2
	NSInteger rating;

}

- (id)initWithLanguage:(BFLanguage*)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating;

+ (BFRatedLanguage *) ratedLanguage:(BFLanguage *)aLanguage tag:(NSInteger)aTag rating:(NSInteger)aRating;

@property (readonly) NSInteger tag;	
@property (assign) NSInteger rating;	

@end
