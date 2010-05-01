//
//  NSString+BFGoogleTranslateEncoderTest.m
//  Babelfish
//
//  Created by Filip Krikava on 5/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GHUnit/GHUnit.h>

#import "NSString+BFGoogleTranslateEncoder.h"

@interface NSString_BFGoogleTranslateEncoderTest : GHTestCase 

@end

@implementation NSString_BFGoogleTranslateEncoderTest

- (void) testNewLinesEncode {
	GHAssertEqualStrings([@"l1\nl3\n\n\nl8\n\n\n\n" stringByEncodingForGoogleTranslate], @"l1 <NL1> l3 <NL3> l8 <NL4> ", @"Line test failed");	
}

- (void) testSpacesEncode {
	GHAssertEqualStrings([@"l1 l2     l3          " stringByEncodingForGoogleTranslate], @"l1 l2 <SP5> l3 <SP10> ", @"Spaces test failed");	
}

- (void) testTabsEncode {
	GHAssertEqualStrings([@"l1\tl2\t\t\tl3\t\t\t\t" stringByEncodingForGoogleTranslate], @"l1 <TB1> l2 <TB3> l3 <TB4> ", @"Tabs test failed");	
}

- (void) testAllEncode {
	GHAssertEqualStrings([@" l0 \t\t l1\n\tl2\n   \n   \tl3\n\t\t\n   \t\n" stringByEncodingForGoogleTranslate], @" l0  <TB2>  l1 <NL1>  <TB1> l2 <NL1>  <SP3>  <NL1>  <SP3>  <TB1> l3 <NL1>  <TB2>  <NL1>  <SP3>  <TB1>  <NL1> ", @"Tabs test failed");	
}

- (void) testSpecialEncode {
	GHAssertEqualStrings([@"<NL2>\n<SP3>\t<TB4> <TB1>   <TB2>" stringByEncodingForGoogleTranslate], @"\\<NL2\\> <NL1> \\<SP3\\> <TB1> \\<TB4\\> \\<TB1\\> <SP3> \\<TB2\\>", @"Tabs test failed");	
	GHAssertEqualStrings([@"\\<NL2\\>\n\\<SP3\\>\t\\<TB4\\> \\<TB1\\>   \\<TB2\\>" stringByEncodingForGoogleTranslate], @"\\\\<NL2\\\\> <NL1> \\\\<SP3\\\\> <TB1> \\\\<TB4\\\\> \\\\<TB1\\\\> <SP3> \\\\<TB2\\\\>", @"Tabs test failed");	
	GHAssertEqualStrings([@"\\\n\\" stringByEncodingForGoogleTranslate], @"\\\\ <NL1> \\\\", @"Tabs test failed");	
}

- (void) testNewLinesDecode {
	GHAssertEqualStrings([@"l1 <NL1> l3 <NL3> l8 <NL4> " stringByDecodingFromGoogleTranslate], @"l1\nl3\n\n\nl8\n\n\n\n", @"Line test failed");	
}

- (void) testSpacesDecode {
	GHAssertEqualStrings([@"l1 l2 <SP5> l3 <SP10> " stringByDecodingFromGoogleTranslate], @"l1 l2     l3          ", @"Spaces test failed");	
}

- (void) testTabsDecode {
	GHAssertEqualStrings([@"l1 <TB1> l2 <TB3> l3 <TB4> " stringByDecodingFromGoogleTranslate], @"l1\tl2\t\t\tl3\t\t\t\t", @"Tabs test failed");	
}

- (void) testAllDecode {
	GHAssertEqualStrings([@" l0  <TB2>  l1 <NL1><TB1> l2 <NL1><SP3><NL1><SP3><TB1> l3 <NL1><TB2><NL1><SP3><TB1><NL1> " stringByDecodingFromGoogleTranslate], @" l0 \t\t l1\n\tl2\n   \n   \tl3\n\t\t\n   \t\n", @"Full test failed");	
}

- (void) testSpecialDecode {
	GHAssertEqualStrings([@"\\<NL2\\> <NL1> \\<SP3\\> <TB1> \\<TB4\\> \\<TB1\\> <SP3> \\<TB2\\>" stringByDecodingFromGoogleTranslate], @"<NL2>\n<SP3>\t<TB4> <TB1>   <TB2>", @"Simple decode escaping test failed");	
	GHAssertEqualStrings([@"\\\\<NL2\\\\> <NL1> \\\\<SP3\\\\> <TB1> \\\\<TB4\\\\> \\\\<TB1\\\\> <SP3> \\\\<TB2\\\\>" stringByDecodingFromGoogleTranslate], @"\\<NL2\\>\n\\<SP3\\>\t\\<TB4\\> \\<TB1\\>   \\<TB2\\>", @"Double escaping decode test failed");	
	GHAssertEqualStrings([@"\\\\ <NL1> \\\\" stringByDecodingFromGoogleTranslate], @"\\\n\\", @"Tabs test failed");	
}

@end
