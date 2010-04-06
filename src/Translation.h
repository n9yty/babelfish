//
//  Translation.h
//  Babelfish
//
//  Created by Filip Krikava on 2/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Translation : NSObject {

	@private
	NSString *originalText;
	NSString *translatedText;
	
	BFRatedLanguage *sourceLanguage;
	BFRatedLanguage *targetLanguge;
	
}

@property (retain) NSString *originalText;
@property (retain) NSString *translatedText;

@property (retain) BFRatedLanguage *sourceLanguage;
@property (retain) BFRatedLanguage *targetLanguage;


@end
