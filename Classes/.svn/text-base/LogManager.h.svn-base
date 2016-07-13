//
//  LogManager.h
//  VisualNotes
//
//  Created by Richard Lucas on 8/15/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SHOW_FULLPATH NO

#define DEBUG 0

#if DEBUG
#define debug(format,...) [[LogManager sharedLog] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]
#else
#define debug(format,...)
#endif

#define WARN 1

#if WARN
#define warn(format,...) [[LogManager sharedLog] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]
#else
#define warn(format,...)
#endif

#define ERROR 1

#if ERROR
#define error(format,...) [[LogManager sharedLog] output:__FILE__ lineNumber:__LINE__ input:(format), ##__VA_ARGS__]
#else
#define error(format,...)
#endif

@interface LogManager : NSObject {
}

+ (LogManager *) sharedLog;

-(void)output:(char*)fileName lineNumber:(int)lineNumber input:(NSString*)input, ...;

@end
