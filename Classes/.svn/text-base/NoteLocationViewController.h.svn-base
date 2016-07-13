//
//  NoteLocationViewController.h
//  VisualNotes
//
//  Created by Richard Lucas on 5/18/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Note.h"

@interface NoteLocationViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate> {
    MKMapView *noteMapView;
    UIBarButtonItem *dismissButton;
    UIBarButtonItem *actionSheetButton;
    Note *note;
}

@property (nonatomic, retain) IBOutlet MKMapView *noteMapView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dismissButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionSheetButton;
@property (nonatomic, retain) Note *note;

- (IBAction) dismissViewAction:(id) sender;
- (IBAction) displayActionSheetAction:(id) sender;

@end
