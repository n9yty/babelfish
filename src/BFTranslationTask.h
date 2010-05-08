//
//  BFTranslationTask.h
//  Babelfish
//
//  Created by Filip Krikava on 5/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BFLanguage;

@interface BFTranslationTask : NSObject {
	@private
	NSString* originalText;
	
	BFLanguage* sourceLanguage;
	BFLanguage* targetLanguage;
}

@property(readonly) NSString* originalText;
@property(readonly) BFLanguage* sourceLanguage;
@property(readonly) BFLanguage* targetLanguage;

- (id) initWithOriginalText:(NSString*) anOriginalText sourceLanguage:(BFLanguage*) aSourceLangauge targetLanguage:(BFLanguage*) aTargetLanguage;

@end
