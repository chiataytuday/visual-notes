// 
//  Note.m
//  VisualNotes
//
//  Created by Richard Lucas on 2/27/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "Note.h"
#import "NSString+Utils.h"


@implementation Note 

@dynamic createdDate;
@dynamic lastModifiedDate;
@dynamic notes;
@dynamic thumbnail;
@dynamic image;
@dynamic noteLatitude;
@dynamic noteLongitude;
@dynamic locationAccuracy;

- (CLLocationCoordinate2D) coordinate {
	CLLocationCoordinate2D captureCoord;
	captureCoord.latitude = [self.noteLatitude doubleValue];
	captureCoord.longitude = [self.noteLongitude doubleValue];
	
	return captureCoord;
}

- (NSString *) title {
	NSString *title = self.notes;
    if (title != nil) {
        if ([title rangeOfString:@"\n"].location != NSNotFound) {
            NSRange range = [title rangeOfString:@"\n"];
            title = [title substringToIndex:range.location];
            title = [NSString trim:title];
        }
    } else {
        title = @" ";
    }

    return title;
}

- (NSString *) subtitle {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.createdDate];
    [dateFormatter release];
    return formattedDateString;
    
}

- (NSString *) googleMapsURL {
    return [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@,%@", self.noteLatitude, self.noteLongitude];
}

@end

@implementation ImageToDataTransformer


+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSData class];
}


- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}


- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return [uiImage autorelease];
}

@end
