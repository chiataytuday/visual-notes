
//
//  LocationManager.m
//  VisualNotes
//
//  Created by Richard Lucas on 6/9/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "LocationManager.h"
#import "LogManager.h"


@implementation LocationManager

@synthesize currentLocation;

static LocationManager *sharedInstance;

+ (LocationManager *)sharedInstance {
    @synchronized(self) {
        if (!sharedInstance)
            sharedInstance = [[LocationManager alloc] init];              
    }
    return sharedInstance;
}

+(id)alloc {
    @synchronized(self) {
        sharedInstance = [super alloc];
    }
    return sharedInstance;
}

-(id) init {
    if ((self = [super init])) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.purpose = @"Visual Notes will geotag notes with their creation location and display it on a map.";
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        locationManager.distanceFilter = 100;
    }
    return self;
}

-(void) start {
    debug(@"%@", ([CLLocationManager locationServicesEnabled] ? @"YES" : @"NO"));
    if ([CLLocationManager locationServicesEnabled] == 1) {
        [locationManager startUpdatingLocation];
        debug(@"Started Location Manager");
    } else {
        debug(@"Location services are not available");
    }

}

-(void) stop {
    [locationManager stopUpdatingLocation];
    debug(@"Stopped Location Manager");
}

-(BOOL) locationKnown {
    if (currentLocation) 
        return YES;
    else
        return NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) { 
        return;           
    } else {
        self.currentLocation = newLocation;
        debug(@"Updated current location. Horizontal Accuracy: %f, Vertical Accuracy: %f", self.currentLocation.horizontalAccuracy, self.currentLocation.verticalAccuracy);
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    warn(@"Unable to get location. Reason: %@", [error description]);
    [self stop];
        
}

@end
