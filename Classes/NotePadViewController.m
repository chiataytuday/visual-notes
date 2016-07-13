//
//  NotePadViewController.m
//  VisualNotes
//
//  Created by Richard Lucas on 3/7/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "NotePadViewController.h"
#import "VisualNotesAppDelegate.h"
#import "UIImage+Utils.h"
#import "NoteLocationViewController.h"
#import "LocationManager.h"
#import "LogManager.h"

@interface NotePadViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
- (void)composeEmail;
- (UIImageView *)createImageView;
@end

@implementation NotePadViewController

@synthesize note, 
notePadView, 
imageScrollView,
textView, 
noteFlipBarButton, 
noteFlipButtonCustomView, 
textButtonView, 
imageButtonView, 
toolbar,
notepaper,
managedObjectContext;

#define kTransitionDuration	0.75
#define kZoomStep 3

// Tags
#define kActionSheetTag 2001
#define kDeleteActionSheetTag 2002
#define kImageViewTag 2002

// Bounds
#define kPortraitHeight 480
#define kPortraitWidth 320
#define kPortraitTextViewHeight 374
#define kPortraitTextViewY 44

#define kLandscapeHeight 320
#define kLandscapeWidth 480
#define kLandscapeTextViewHeight 225
#define kLandscapeTextViewY 38

#define kimageScrollViewY -20


#pragma mark -
#pragma mark View Methods

- (void)setupNotePadView {       
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.notePadView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, kLandscapeWidth, kLandscapeHeight)];
        notepaper = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, kLandscapeWidth, kLandscapeHeight)]; 
        notepaper.image = [UIImage imageNamed:@"note-text-view-background-landscape"];
        [self.notePadView addSubview: notepaper];
        [self.notePadView sendSubviewToBack: notepaper];
        self.textView = [[[UITextView alloc] initWithFrame: CGRectMake(0, kLandscapeTextViewY, kLandscapeWidth, kLandscapeTextViewHeight)] autorelease];
    } else {
        self.notePadView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, kPortraitWidth, kPortraitHeight)];
        notepaper = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, kPortraitWidth, kPortraitHeight)]; 
        notepaper.image = [UIImage imageNamed:@"note-text-view-background"];
        [self.notePadView addSubview: notepaper];
        [self.notePadView sendSubviewToBack: notepaper];
        self.textView = [[[UITextView alloc] initWithFrame: CGRectMake(0, kPortraitTextViewY, kPortraitWidth, kPortraitTextViewHeight)] autorelease];
    }
    
    self.textView.textColor = [UIColor blackColor];
    self.textView.opaque = NO;
	self.textView.font = [UIFont fontWithName:@"Trebuchet MS" size:16];
	self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;
	self.textView.scrollEnabled = YES;
	self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    // Data Detectors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [defaults boolForKey:@"enableDataDetectors"];
    if (enabled) {
        self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
        self.textView.editable = FALSE;
        UILongPressGestureRecognizer *longTouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTouchText:)];
        [longTouch setNumberOfTouchesRequired:1];
        [longTouch setMinimumPressDuration:0.3];
        [textView addGestureRecognizer:longTouch];
        [longTouch release];
    } else {
       self.textView.editable = TRUE; 
    }
    
    if (self.note != nil) {
        self.textView.text = note.notes;
    }
    
	[self.notePadView addSubview: self.textView];
}

- (void)setupNoteImageView {      
    CGFloat zoomScale;
    UIImageView *imageView = [self createImageView];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        imageScrollView = [[CustomUIScrollView alloc] initWithFrame: CGRectMake(0, kimageScrollViewY, kLandscapeWidth, kLandscapeHeight)];
        zoomScale = [imageScrollView frame].size.height  / [imageView frame].size.height;
    } else {
        imageScrollView = [[CustomUIScrollView alloc] initWithFrame: CGRectMake(0, kimageScrollViewY, kPortraitWidth, kPortraitHeight)];
        UIImageView *imageView = [self createImageView];            
        zoomScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
    }
    self.navigationItem.rightBarButtonItem = noteFlipBarButton;
    [imageScrollView setBackgroundColor:[UIColor blackColor]];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setChildView:imageView];
    [imageScrollView setMinimumZoomScale:zoomScale];
    [imageScrollView setZoomScale:zoomScale];
}

- (UIImageView *)createImageView {
    UIImage *image = [note.image valueForKey:@"image"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setTag:kImageViewTag];
    [imageView setUserInteractionEnabled:YES];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    [imageView setBackgroundColor:[UIColor blackColor]];
    UILongPressGestureRecognizer *longTouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTouchImage:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapImage:)];
    [longTouch setNumberOfTouchesRequired:1];
    [longTouch setMinimumPressDuration:0.2];
    [doubleTap setNumberOfTapsRequired:2];
    [imageView addGestureRecognizer:longTouch];
    [imageView addGestureRecognizer:doubleTap];
    [longTouch release];
    [doubleTap release];
    return [imageView autorelease];
}

- (void)setupNavigationBarButtons {
    UIImageView *textButtonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(5, 5, 19, 21)];
    textButtonImageView.image = [UIImage imageNamed:@"flip-icon"];
    textButtonImageView.backgroundColor = [UIColor clearColor];
    
    UIButton * textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    textButton.frame = CGRectMake(0, 0, 30, 30);
    [textButton setBackgroundColor:[UIColor clearColor]];
    [textButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
    [textButton addSubview:textButtonImageView];
    [textButtonImageView release];
    
    textButtonView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 30, 30)];
    [textButtonView addSubview:textButton];
    
    UIImageView *imageButtonImageView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, 30, 30)];
    imageButtonImageView.image = note.thumbnail;
    imageButtonImageView.backgroundColor = [UIColor blackColor];
    
    UIButton * imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.frame = CGRectMake(0, 0, 30, 30);
    [imageButton setBackgroundColor:[UIColor clearColor]];
    [imageButton addTarget:self action:@selector(flipAction:) forControlEvents:UIControlEventTouchUpInside];
    [imageButton addSubview:imageButtonImageView];
    [imageButtonImageView release];
    
    imageButtonView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 30, 30)];
    [imageButtonView addSubview:imageButton];
    
    noteFlipButtonCustomView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 30, 30)];
    [noteFlipButtonCustomView addSubview:textButtonView];
    noteFlipBarButton = [[UIBarButtonItem alloc] initWithCustomView:noteFlipButtonCustomView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    didZoom = NO;
    fullScreen = NO;
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    if (self.note == nil) {
        UIBarButtonItem* dismissItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction:)];
        self.navigationItem.leftBarButtonItem = dismissItem;
        [dismissItem release];
    } else {
        self.title = [note title]; 
    }
    
    
    [self setupNoteImageView];
	[self setupNotePadView];
    [self setupNavigationBarButtons];
    
    if (self.note.image == nil) {
        [self.view addSubview:notePadView];
    } else {
        [self.view addSubview:imageScrollView];
        self.navigationItem.rightBarButtonItem = noteFlipBarButton;
    }
    
    toolbar = [UIToolbar new];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [toolbar sizeToFit];
    CGFloat toolbarHeight = [toolbar frame].size.height;
    CGRect mainViewBounds = self.view.bounds;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        mainViewBounds = CGRectMake(0, 5, 480, 300); // TODO Figure out how to calulate this!
    }
    CGRect toolbarFrame = CGRectMake(0, CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight / 2), CGRectGetWidth(mainViewBounds), toolbarHeight);
    [toolbar setFrame:CGRectMake(toolbarFrame.origin.x, toolbarFrame.origin.y, toolbarFrame.size.width, toolbarFrame.size.height)];

       
    UIBarButtonItem *spacer = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:NULL action:NULL] autorelease];
    UIBarButtonItem *actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(dislpayActionSheet:)] autorelease];
    UIBarButtonItem *deleteButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(displayDeleteActionSheet:)] autorelease];
    
    if (self.note == nil) {
        [deleteButton setEnabled:NO];
        [actionButton setEnabled:NO];
    }
    
    [toolbar setItems:[NSArray arrayWithObjects:deleteButton, spacer, actionButton, nil]];
    [self.navigationController.view addSubview:toolbar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // listen for keyboard hide/show notifications so we can properly adjust the table's height
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.navigationController.view addSubview:toolbar];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [toolbar removeFromSuperview];
}

- (void)viewDidDisappear:(BOOL)animated  {   
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];	
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {            
    CGFloat y = 0;
    CGFloat toolBarYOffset = 5;
    if ([imageScrollView superview]) {
        y = kimageScrollViewY;
        if (self.navigationController.navigationBarHidden) {
            y=0;
            toolBarYOffset = kimageScrollViewY;
        }
    }    
    
    // Change the image scroll view frame size to match the orientation, add the image view to the scroll view to resize it and recalculate the zoom scale.
    CGFloat zoomScale;
    UIImageView *imageView = [self createImageView];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        
        imageScrollView.frame = CGRectMake(0, y, kLandscapeWidth, kLandscapeHeight);
        [imageScrollView setChildView:imageView];
        zoomScale = [imageScrollView frame].size.height  / [imageView frame].size.height;
        
        self.notePadView.frame = CGRectMake(0, 0, kLandscapeWidth, kLandscapeHeight);
        self.notepaper.frame = CGRectMake(0, 0, kLandscapeWidth, kLandscapeHeight); 
        self.notepaper.image = [UIImage imageNamed:@"note-text-view-background-landscape"];
        self.textView.frame = CGRectMake(0, kLandscapeTextViewY, kLandscapeWidth, kLandscapeTextViewHeight);
    } else {
        self.imageScrollView.frame = CGRectMake(0, y, kPortraitWidth, kPortraitHeight);
        UIImageView *imageView = [self createImageView];            
        [imageScrollView setChildView:imageView];
        zoomScale = [imageScrollView frame].size.width  / [imageView frame].size.width;
        
        self.notePadView.frame = CGRectMake(0, 0, kPortraitWidth, kPortraitHeight);
        self.notepaper.frame = CGRectMake(0, 0, kPortraitWidth, kPortraitHeight); 
        self.notepaper.image = [UIImage imageNamed:@"note-text-view-background"];
        self.textView.frame = CGRectMake(0, kPortraitTextViewY, kPortraitWidth, kPortraitTextViewHeight);
    }
    
    // Update the zoom scale and set accordingly
    [imageScrollView setMinimumZoomScale:zoomScale];
    [imageScrollView setZoomScale:zoomScale];
    if (didZoom) {
        [imageScrollView setZoomScale:(zoomScale * kZoomStep)];
    } else {
        [imageScrollView setZoomScale:(zoomScale)];
    }
    
    // Resize the toolbar to match the orientation
    CGFloat toolbarHeight = [toolbar frame].size.height;
    CGRect mainViewBounds = self.view.bounds;
    NSLog(@" rotate %f %f ", CGRectGetMinY(mainViewBounds),CGRectGetHeight(mainViewBounds));
    CGRect toolbarFrame = CGRectMake(0, CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - (toolbarHeight / 2) + toolBarYOffset, CGRectGetWidth(mainViewBounds), toolbarHeight);
    [toolbar setFrame:CGRectMake(toolbarFrame.origin.x, toolbarFrame.origin.y, toolbarFrame.size.width, toolbarFrame.size.height)];
}

#pragma mark -
#pragma mark Actions

- (void)flipAction:(id)sender {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
    
	[UIView setAnimationTransition:([self.notePadView superview] ?
                                    UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:self.view cache:YES];
	if ([imageScrollView superview]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
        [self.imageScrollView removeFromSuperview];
		[self.view addSubview:notePadView];
    } else {
		[self.notePadView removeFromSuperview];
		[self.view addSubview:imageScrollView];
	}
	
	[UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kTransitionDuration];
    
    [UIView setAnimationTransition:([self.notePadView superview] ?
                                    UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
                           forView:noteFlipButtonCustomView cache:YES];
    
    if ([imageButtonView superview]) {
        [imageButtonView removeFromSuperview];
        [noteFlipButtonCustomView addSubview:textButtonView];
    }
    else {
        [textButtonView removeFromSuperview];
        [noteFlipButtonCustomView addSubview:imageButtonView];
    }
	
	[UIView commitAnimations];
}

- (void)saveNoteAction:(id)sender {
    
    NSDate *now = [[NSDate alloc] init];
    
    if (self.note != nil && textView.text.length == 0) {
        self.note.notes = nil;
        self.note.lastModifiedDate = now;
    } else if (textView.text.length != 0) {
        
        // Create a new note if one does not exist
        if (self.note == nil) {
            Note *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
            self.note = newNote;
            self.note.createdDate = now;
            LocationManager *locationManager = [LocationManager sharedInstance];
            if ([locationManager locationKnown]) {
                CLLocation *currentLocation = [locationManager currentLocation]; 
                CLLocationCoordinate2D coordinate = [currentLocation coordinate];
                [note setNoteLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
                [note setNoteLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
                [note setLocationAccuracy:[NSNumber numberWithDouble:currentLocation.horizontalAccuracy]];
                debug(@"Setting notes location. Latitude: %f Longitude: %f Accuracy: %f", coordinate.latitude, coordinate.longitude, currentLocation.horizontalAccuracy);
            }
            
            [locationManager stop];
        }
        self.note.lastModifiedDate = now;
        self.note.notes = textView.text;
        self.title = [note title];
    }
    
    [now release];
    
    [self.textView resignFirstResponder];
    if (self.note.image != nil) {
        self.navigationItem.rightBarButtonItem = noteFlipBarButton;   
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    // Data Detectors
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL enabled = [defaults boolForKey:@"enableDataDetectors"];
    if (enabled) {
        self.textView.editable = FALSE;
        UILongPressGestureRecognizer *longTouch = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongTouchText:)];
        [longTouch setNumberOfTouchesRequired:1];
        [longTouch setMinimumPressDuration:0.3];
        [textView addGestureRecognizer:longTouch];
        [longTouch release];
    }
}

- (void)dismissAction:(id)sender {
    if (self.note == nil) {
        [[LocationManager sharedInstance] stop];
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)deleteAction:(id)sender {
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Note" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil, nil];
    [deleteActionSheet showInView:self.view];
    [deleteActionSheet release];    
}

#pragma mark -
#pragma mark Action Sheets

- (void)dislpayActionSheet:(id)sender {
    UIActionSheet *actionSheet;
    if ([self.note.noteLatitude isEqualToNumber:[NSNumber numberWithFloat:0.000000]]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Note", nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Email Note", @"Map", nil];
    }
    
    actionSheet.tag = kActionSheetTag;
    [actionSheet showInView:self.view];
    [actionSheet release];    
}

- (void)displayDeleteActionSheet:(id)sender {
    UIActionSheet *deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Note" delegate:self cancelButtonTitle:@"No" destructiveButtonTitle:@"Yes" otherButtonTitles:nil, nil];
    deleteActionSheet.tag = kDeleteActionSheetTag;
    [deleteActionSheet showInView:self.view];
    [deleteActionSheet release];    
}

#pragma mark -
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)aNotification {
	CGRect keyboardRect = [[[aNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect frame = self.textView.frame;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        frame.size.height -= 100    ; // TODO Figure out how to calulate this!
    } else {
        frame.size.height -= (keyboardRect.size.height - 40);
    }
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.textView.frame = frame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    NSTimeInterval animationDuration = [[[aNotification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.textView.frame = CGRectMake(0, kLandscapeTextViewY, kLandscapeWidth, kLandscapeTextViewHeight);
    } else {
        self.textView.frame = CGRectMake(0, kPortraitTextViewY, kPortraitWidth, kPortraitTextViewHeight);
    }
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveNoteAction:)];
	self.navigationItem.rightBarButtonItem = saveItem;
	[saveItem release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    if (actionSheet.tag == kDeleteActionSheetTag) {
        switch (buttonIndex) {
            case 0:
                if (self.note != nil) {
                    [managedObjectContext deleteObject:self.note];
                }
                [[self navigationController] popViewControllerAnimated: YES];
                return;
            default:
                return;
        }
    } else if (actionSheet.tag == kActionSheetTag) {
        if ([self.note.noteLatitude isEqualToNumber:[NSNumber numberWithFloat:0.000000]]) {
            switch (buttonIndex) {
                case 0:
                    if (self.note != nil) {
                        [self composeEmail];
                    }
                    return;
                default:
                    return;
            }
        } else {
            switch (buttonIndex) {
                case 0:
                    if (self.note != nil) {
                        [self composeEmail];
                    }
                    return;
                case 1:
                    if (self.note != nil) {
                        NoteLocationViewController *controller = [[NoteLocationViewController alloc] initWithNibName:@"NoteLocationView" bundle:nil];
                        controller.note = self.note;
                        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                        [self presentModalViewController:controller animated:YES];
                        [controller release];
                    }
                default:
                    return;
            }
        }
    }
    
}

#pragma mark -
#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [imageScrollView viewWithTag:kImageViewTag];
}

#pragma mark -
#pragma mark Gesture Recongnizer methods

- (void)handleLongTouchText:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        self.textView.editable = TRUE;
        [self.textView becomeFirstResponder];
        [self.textView removeGestureRecognizer:gestureRecognizer];
    }
}

// Single tap moves between normal and full screen mode
- (void)handleLongTouchImage:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (fullScreen) {
            CGRect rect;
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                rect = CGRectMake(0, kimageScrollViewY, kLandscapeWidth, kLandscapeHeight);
            } else {
                rect = CGRectMake(0, kimageScrollViewY, kPortraitWidth, kPortraitHeight);
            }
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            self.toolbar.hidden = NO;
            self.imageScrollView.frame = rect;
            fullScreen = NO;
        } else {
            CGRect rect;
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                rect = CGRectMake(0, 0, kLandscapeWidth, kLandscapeHeight);
            } else {
                rect = CGRectMake(0, 0, kPortraitWidth, kPortraitHeight);
            }
            
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            [self.navigationController setNavigationBarHidden:YES];
            self.toolbar.hidden = YES;
            self.imageScrollView.frame = rect;
            fullScreen = YES;
        }
    }
}

// Double tap zooms/unzooms the image
- (void)handleDoubleTapImage:(UIGestureRecognizer *)gestureRecognizer {
    if (didZoom) {
        CGFloat zoomScale = [imageScrollView zoomScale] / kZoomStep;
        CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [imageScrollView zoomToRect:zoomRect animated:YES];
        didZoom = NO;
    } else {
        CGFloat zoomScale = [imageScrollView zoomScale] * kZoomStep;
        CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [imageScrollView zoomToRect:zoomRect animated:YES];
        didZoom = YES;
    }
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

- (void)composeEmail {    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    [picker setSubject:[self.note title]];
    NSString *googleMapsLink = nil;
    if (![self.note.noteLatitude isEqualToNumber:[NSNumber numberWithFloat:0.000000]]) {
        googleMapsLink = [NSString stringWithFormat:@"<a href=\"%@\">View On Map</a>", note.googleMapsURL]; 
    }
    NSString *emailBody = note.notes;
    if (emailBody == nil) {
        if (googleMapsLink != nil) {
            emailBody = googleMapsLink;
        }
    } else {
        if (googleMapsLink != nil) {
            emailBody = [emailBody stringByAppendingString:@"<p>"];
            emailBody = [emailBody stringByAppendingString:googleMapsLink];
        }
    }
    [picker setMessageBody:emailBody isHTML:YES];
    if (note.image != nil) {
        NSData *data = UIImagePNGRepresentation([note.image valueForKey:@"image"]);
        [picker addAttachmentData:data mimeType:@"image/png" fileName:@"note"];
    }
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[textView release];
    [note release];
    [notePadView release];
    [imageScrollView release];
    [noteFlipBarButton release];
    [noteFlipButtonCustomView release];
    [textButtonView release];
    [imageButtonView release];
    [toolbar release];
    [notepaper release];
    [managedObjectContext release];
	[super dealloc];
}

@end
