/*
 *  BFDefines.h
 *  Babelfish
 *
 *  Created by Filip Krikava on 5/2/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

// following assertions were taken from: GMTDefines.h from the google-mac-toolbox:
// http://code.google.com/p/google-toolbox-for-mac/

#ifndef BFDevLog

#ifndef NDEBUG
#define BFDevLog(...) NSLog(__VA_ARGS__)
#else
#define BFDevLog(...) do { } while (0)
#endif // NDEBUG

#endif // BFDEVLOG

#ifndef BFStr
#define BFStr(fmt,...) [NSString stringWithFormat:fmt,##__VA_ARGS__]
#endif BFStr // BFStr

#ifndef BFTraceLog

#ifndef NTRACE
#define BFTraceLog(...) NSLog(@"%@: %@",BFStr(@"[\%s:\%s:\%d]",__PRETTY_FUNCTION__,__FILE__,__LINE__),BFStr(__VA_ARGS__))
#define BFTrace() NSLog(@"[\%s:\%s:\%d]",__PRETTY_FUNCTION__,__FILE__,__LINE__)
#endif // NTRACE

#endif // BFTraceLog

#ifndef BFAssert

#if !defined(NS_BLOCK_ASSERTIONS)

#define BFAssert(condition, ...)                                       \
do {                                                                      \
if (!(condition)) {                                                     \
[[NSAssertionHandler currentHandler]                                  \
handleFailureInFunction:[NSString stringWithUTF8String:__PRETTY_FUNCTION__] \
file:[NSString stringWithUTF8String:__FILE__]  \
lineNumber:__LINE__                                  \
description:__VA_ARGS__];                             \
}                                                                       \
} while(0)

#else // !defined(NS_BLOCK_ASSERTIONS)
#define BFAssert(condition, ...) do { } while (0)
#endif // !defined(NS_BLOCK_ASSERTIONS)

#endif // BFAssert

#ifndef BFFail

#define BFFail(...) BFAssert(NO,##__VA_ARGS__)

#endif // BFFail

// TODO refactor
static inline BOOL isEmpty(id thing) {
    return thing == nil
	|| ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
	|| ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}
