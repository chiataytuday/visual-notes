//
//  NoteLocationViewController.m
//  VisualNotes
//
//  Created by Richard Lucas on 5/18/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "NoteLocationViewController.h"
#import "LogManager.h"


@implementation NoteLocationViewController

@synthesize note, noteMapView, dismissButton, actionSheetButton;

#pragma mark -
#pragma mark View lifecycle

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    CLLocationDistance accuracyRadius = 0;
    if (note.locationAccuracy != nil && [note.locationAccuracy doubleValue] > 100) {
        accuracyRadius = [note.locationAccuracy doubleValue];
    }
	
    CLLocationCoordinate2D mapCenter;
    mapCenter.latitude = [note.noteLatitude doubleValue];
    mapCenter.longitude = [note.noteLongitude doubleValue];
    
    MKCoordinateSpan mapSpan;
    mapSpan.latitudeDelta = 0.005;
    mapSpan.longitudeDelta = 0.005;
    
    // if radius is greater than 500 meters zoom the map accordingly
    if (accuracyRadius > 500) {
        double delta = accuracyRadius / 50000;
        mapSpan.latitudeDelta = delta;
        mapSpan.longitudeDelta = delta;
    }
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = mapCenter;
    mapRegion.span = mapSpan;
    
    self.noteMapView.region = mapRegion;
    self.noteMapView.mapType = MKMapTypeStandard;
    [self.noteMapView addAnnotation:self.note];



    [self.noteMapView addOverlay: [MKCircle circleWithCenterCoordinate:mapCenter radius:accuracyRadius]];
    
    debug(@"Displaying the loation of note \"%@\" on map. [Accuracy: %f Latitude: %f Delta: %f Longitude: %f Delta: %f ", 
          note.title, accuracyRadius, mapCenter.latitude, mapSpan.latitudeDelta, mapCenter.longitude, mapSpan.longitudeDelta);
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[noteMapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (!pinView) {
        MKPinAnnotationView* customPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
        customPinView.pinColor = MKPinAnnotationColorRed;
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        if (note.thumbnail != nil) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:note.thumbnail];
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, 30, 30);
            customPinView.leftCalloutAccessoryView = imageView;
            [imageView release];
        }

        return customPinView;
    }
    else {
        pinView.annotation = annotation;
    }
    return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
	MKOverlayView *result = [[[MKCircleView alloc] initWithCircle:(MKCircle *)overlay] autorelease];
    [(MKOverlayPathView *)result setFillColor:[[UIColor blueColor] colorWithAlphaComponent:0.3]];
	return result;
}

#pragma mark -
#pragma mark Actions


- (IBAction) dismissViewAction:(id) sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction) displayActionSheetAction:(id) sender {
    UIActionSheet *locationViewActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Maps", nil];
    [locationViewActionSheet showInView:self.view];
    [locationViewActionSheet release]; 
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            NSString *googleMapsURL = self.note.googleMapsURL;
            debug(@"Opening Maps Application with URI: %@", googleMapsURL);
            UIApplication *app = [UIApplication sharedApplication];  
            [app openURL:[NSURL URLWithString:googleMapsURL]];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[note release];
	[noteMapView release];
    [dismissButton release];
    [actionSheetButton release];
    [super dealloc];
}

@end
