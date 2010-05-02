//
//  NSString+BFGoogleTranslateEncoder.m
//  Babelfish
//
//  Created by Filip Krikava on 5/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "RegexKitLite.h"

#import "NSString+BFGoogleTranslateEncoder.h"
#import "BFDefines.h"

NSString *const BFSymbols[3][3] = {
	{@" " ,@"{2,}",@"SP"},
	{@"\n",@"+",@"NL"},
	{@"\t",@"+",@"TB"},
}; 

@implementation NSString (BFGoogleTranslateEncoderAdditions)

- (NSString *) stringByEncodingForGoogleTranslate {
		
	NSString *encodedString = self;
	
	// espace any of the symbols that might have been preset
	encodedString = [encodedString stringByReplacingOccurrencesOfRegex:@"\\\\" withString:@"\\\\\\\\"];
	
	for (int i = 0; i<3; i++) {
		NSString *regexp = [NSString stringWithFormat:@"<%@(\\d+)>", BFSymbols[i][2]]; 
		NSString *rep = [NSString stringWithFormat:@"\\\\<%@$1\\\\>", BFSymbols[i][2]]; 
		encodedString = [encodedString stringByReplacingOccurrencesOfRegex:regexp withString:rep];
	}
	
	for (int i = 0; i<3; i++) {
		NSString *testSymbolRegExp = [NSString stringWithFormat:@"[%@]%@", BFSymbols[i][0], BFSymbols[i][1]]; 
		NSString *outputSymbol = BFSymbols[i][2];
		
		NSError *error = nil;
		encodedString = [encodedString stringByReplacingOccurrencesOfRegex:testSymbolRegExp options:RKLNoOptions inRange:NSMakeRange(0UL, [encodedString length]) error:&error enumerationOptions:RKLRegexEnumerationNoOptions usingBlock:
		^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
			
			NSString *s = [NSString stringWithFormat:@" <%@%d> ", outputSymbol, [capturedStrings[0] length]];
		
//			BFDevLog(@"\"%@\" - %d \"%@\"", capturedStrings[0], [capturedStrings[0] length], s);
		
			return s;
		}];
		BFAssert(error == nil, @"Error in the regular expression %@", error);	
//		BFDevLog(@" %@ -- %@", error, encodedString);
	}
	
	return encodedString;	
}

- (NSString *) stringByDecodingFromGoogleTranslate {

	NSString *encodedString = self;
	
	for (int i = 2; i>=0; i--) {
		NSString *testSymbolRegExp = [NSString stringWithFormat:@"[ ]?<%@(\\d+)>[ ]?", BFSymbols[i][2]]; 
		NSString *outputSymbol = BFSymbols[i][0];
		
		NSError *error = nil;
		encodedString = [encodedString stringByReplacingOccurrencesOfRegex:testSymbolRegExp options:RKLNoOptions inRange:NSMakeRange(0UL, [encodedString length]) error:&error enumerationOptions:RKLRegexEnumerationNoOptions usingBlock:
		^NSString *(NSInteger captureCount, NSString * const capturedStrings[captureCount], const NSRange capturedRanges[captureCount], volatile BOOL * const stop) {
			
			int count = [capturedStrings[1] intValue];
			
			NSMutableString *s = [NSMutableString stringWithCapacity:count];
			for (int i=0; i<count; i++) {
				[s appendString:outputSymbol];
			}
			
			//			BFDevLog(@"\"%@\" - %d \"%@\"", capturedStrings[0], count, s);
			
			return [NSString stringWithString:s];
		}];
		BFAssert(error == nil, @"Error in the regular expression %@", error);	
		//		BFDevLog(@" %@ -- %@", error, encodedString);
	}
	
	for (int i = 0; i<3; i++) {
		NSString *regexp = [NSString stringWithFormat:@"\\\\<%@(\\d+)\\\\>", BFSymbols[i][2]]; 
		NSString *rep = [NSString stringWithFormat:@"<%@$1>", BFSymbols[i][2]]; 
		encodedString = [encodedString stringByReplacingOccurrencesOfRegex:regexp withString:rep];
	}

	// espace any of the symbols that might have been preset
	encodedString = [encodedString stringByReplacingOccurrencesOfRegex:@"\\\\\\\\" withString:@"\\\\"];
	
	return encodedString;	
	
}


@end
