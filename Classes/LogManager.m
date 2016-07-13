//
//  LogManager.m
//  VisualNotes
//
//  Created by Richard Lucas on 8/15/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "LogManager.h"

@implementation LogManager

static LogManager *sharedLogInstance = nil;

+ (LogManager *) sharedLog {
    
    @synchronized(self) {
        if (!sharedLogInstance)
            sharedLogInstance = [[self alloc] init];             
    }
    return sharedLogInstance;
}

+ (id) allocWithZone:(NSZone *) zone {
    @synchronized(self) {
        if (sharedLogInstance == nil) {
            sharedLogInstance = [super allocWithZone:zone];
            return sharedLogInstance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}


- (unsigned)retainCount {
    return UINT_MAX;
}


- (id)autorelease {
    return self;
}


-(void)output:(char*)fileName lineNumber:(int)lineNumber input:(NSString*)input, ... {
    va_list argList;
    NSString *filePath, *formatStr;
    
    // Build the path string
    filePath = [[NSString alloc] initWithBytes:fileName length:strlen(fileName) encoding:NSUTF8StringEncoding];
    
    // Process arguments, resulting in a format string
    va_start(argList, input);
    formatStr = [[NSString alloc] initWithFormat:input arguments:argList];
    va_end(argList);
    
    // Call NSLog, prepending the filename and line number
    NSLog(@"File:%s Line:%d %@",[((SHOW_FULLPATH) ? filePath :[filePath lastPathComponent]) UTF8String], lineNumber, formatStr);
    
    [filePath release];
    [formatStr release];
}
@end
