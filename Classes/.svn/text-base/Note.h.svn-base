//
//  Note.h
//  VisualNotes
//
//  Created by Richard Lucas on 2/27/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface ImageToDataTransformer : NSValueTransformer {
}
@end

@interface Note :  NSManagedObject <MKAnnotation>  
{
}

@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSDate * lastModifiedDate;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) UIImage *thumbnail;
@property (nonatomic, retain) NSManagedObject * image;
@property (nonatomic, retain) NSNumber * noteLatitude;
@property (nonatomic, retain) NSNumber * noteLongitude;
@property (nonatomic, retain) NSNumber * locationAccuracy;

- (NSString *)googleMapsURL;

#pragma mark -
#pragma mark MapKit Annotation Protocol

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSString *)title;
- (NSString *)subtitle;

@end



