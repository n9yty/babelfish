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
	
	RatedLanguage *sourceLanguage;
	RatedLanguage *targetLanguge;
	
}

@property (retain) NSString *originalText;
@property (retain) NSString *translatedText;

@property (retain) RatedLanguage *sourceLanguage;
@property (retain) RatedLanguage *targetLanguage;


@end
