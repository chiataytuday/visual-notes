//
//  NSString+Utils.h
//  VisualNotes
//
//  Created by Richard Lucas on 3/13/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

+ (NSString *)trim:(NSString *)original {
	NSMutableString *copy = [original mutableCopy];
    NSString *trimmedString = [NSString stringWithString:[copy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [copy release];
	return trimmedString;
}

+ (BOOL)isEmpty:(NSString *)string {
	if (string == nil || [[self trim:string] length] == 0) {
        return YES;
    } else {
        return NO;
    }
}

@end