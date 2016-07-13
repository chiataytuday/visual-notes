//
//  NoteListViewController.m
//  VisualNotes
//
//  Created by Richard Lucas on 2/21/10.
//  Copyright lucasweb 2010. All rights reserved.
//

#import "NoteListViewController.h"
#import "Note.h"
#import "NotePadViewController.h"
#import "UIImage+Utils.h"
#import "NoteCellView.h"
#import "LocationManager.h"
#import "LogManager.h"
#import "InAppSettings.h"

@interface NoteListViewController (UtilityMethods)
- (NSUInteger)getNoteCount;
- (void)saveManagedContext;
@end

@implementation NoteListViewController

@synthesize fetchedResultsController, managedObjectContext, backgroundViewPortrait, backgroundViewLandscape;

#define kMaxNotesAlertView 30001

#pragma mark -
#pragma mark Construct views

- (void)setupTableView {
    self.tableView.backgroundColor = [UIColor clearColor]; 
    
    backgroundViewPortrait = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table-view-background"]];
    backgroundViewLandscape = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table-view-background-landscape"]];
    
    [self.navigationController.view addSubview:backgroundViewPortrait];
    [self.navigationController.view sendSubviewToBack:backgroundViewPortrait];
    
    self.tableView.rowHeight = 50.0;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // Add note button
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNote:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    [addButtonItem release];
    
    // Add settings button
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings-icon"] style:UIBarButtonItemStyleBordered target:self action:@selector(presentSettings:)];
    self.navigationItem.leftBarButtonItem = settingsBarButton;
    [settingsBarButton release];
}

- (void)setControllerTitle {
    
    NSUInteger count = [self getNoteCount];
    
    if (count != 0) {
        self.title = [NSString stringWithFormat:@"Visual Notes (%d)", count];
    } else {
        self.title = @"Visual Notes";
    }
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    
    // Fetch the first n notes
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error]) {
		error(@"An error occured retrieving fetched results. %@, %@", error, [error userInfo]);
		// Display an alert message if an error occurs
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Visual Notes failed to start! \n\nPlease exit the application by pressing the home button." 
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [alert release];
	}
    
    [self setControllerTitle];

    // Set the Navigation Bar style
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    // Create Navigate Bar 'Back' Button, this is used by subsequent view controllers to navigate back to the root view controller
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self.navigationController.view addSubview:backgroundViewLandscape];
        [self.navigationController.view sendSubviewToBack:backgroundViewLandscape];
    } else {
        [self.navigationController.view addSubview:backgroundViewPortrait];
        [self.navigationController.view sendSubviewToBack:backgroundViewPortrait];
    }
    [self.tableView reloadData];
}

-(void) viewDidDisappear:(BOOL)animated {
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [backgroundViewLandscape removeFromSuperview];
    } else {
        [backgroundViewPortrait removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation { 
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {    
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [backgroundViewPortrait removeFromSuperview];
        [self.navigationController.view addSubview:backgroundViewLandscape];
        [self.navigationController.view sendSubviewToBack:backgroundViewLandscape];
    } else {
        [backgroundViewLandscape removeFromSuperview];
        [self.navigationController.view addSubview:backgroundViewPortrait];
        [self.navigationController.view sendSubviewToBack:backgroundViewPortrait];
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Actions

- (void)addNote:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Add Visual Note" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
                                                             otherButtonTitles:@"Camera", @"Photo Library", @"Text", nil];
		[photoSourceSheet showInView:self.view];
		[photoSourceSheet release];
	} else {
        UIActionSheet *photoSourceSheet = [[UIActionSheet alloc] initWithTitle:@"Add Visual Note" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil 
                                                             otherButtonTitles:@"Photo Library", @"Text", nil, nil];
		[photoSourceSheet showInView:self.view];
		[photoSourceSheet release];
    }
}

- (void)presentSettings:(id)sender {
    InAppSettingsModalViewController *settings = [[InAppSettingsModalViewController alloc] init];
    [self presentModalViewController:settings animated:YES];
    [settings release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate methods

- (void) actionSheet: (UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch (buttonIndex) {
            case 0:
                debug(@"Add Note - Camera Selected");
                [[LocationManager sharedInstance] start];
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentModalViewController:picker animated:YES];
                break;
            case 1:
                debug(@"Add Note - Photo Library Selected");
                [[LocationManager sharedInstance] start];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:picker animated:YES];
                break;
            case 2:
                debug(@"Add Note - Text Only Selected");
                [[LocationManager sharedInstance] start];
                NotePadViewController *notePadController = [[NotePadViewController alloc] initWithNibName:@"NotePadView" bundle:nil];
                notePadController.managedObjectContext = self.managedObjectContext;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:notePadController];
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
                [notePadController release];
                [picker release];                
                break;
            default:
                [picker release];
                return;
        }
    } else {
        switch (buttonIndex) {
            case 0:
                debug(@"Add Note - Photo Library Selected");
                [[LocationManager sharedInstance] start];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentModalViewController:picker animated:YES];
                break;
            case 1:
                debug(@"Add Note - Text Only Selected");
                [[LocationManager sharedInstance] start];
                NotePadViewController *notePadController = [[NotePadViewController alloc] initWithNibName:@"NotePadView" bundle:nil];
                notePadController.managedObjectContext = self.managedObjectContext;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:notePadController];
                [self presentModalViewController:navigationController animated:YES];
                [navigationController release];
                [notePadController release];
                [picker release];                
                break;
            default:
                [picker release];
                return;
        }
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage* selectedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Create an image object for the new image.
    NSManagedObject *image = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:managedObjectContext];
    
    // Set the image for the image managed object.
    [image setValue:[selectedImage scaleAndCropImageToScreenSize] forKey:@"image"];
    
    // Create a thumbnail version of the image.
    UIImage *imageThumbnail = [selectedImage thumbnailImage:50.0F];
    
    // Create a new note
    Note *note = [NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:managedObjectContext];
    NSDate *now = [[NSDate alloc] init];
    note.createdDate = now;
    note.lastModifiedDate = now;
    [now release];
    note.thumbnail = imageThumbnail;
    note.image = image;

    LocationManager *locationManager = [LocationManager sharedInstance];
    if ([locationManager locationKnown]) {
        CLLocation *currentLocation = [locationManager currentLocation]; 
        CLLocationCoordinate2D coordinate = [currentLocation coordinate];
        [note setNoteLatitude:[NSNumber numberWithDouble:coordinate.latitude]];
        [note setNoteLongitude:[NSNumber numberWithDouble:coordinate.longitude]];
        [note setLocationAccuracy:[NSNumber numberWithDouble:currentLocation.horizontalAccuracy]];
    }
    
    [locationManager stop];
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[LocationManager sharedInstance] stop];
	[self dismissModalViewControllerAnimated:YES];
	[picker release];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex {
    if (alertView.tag == kMaxNotesAlertView) {
        if (buttonIndex==1) {
            NSString *iTunesLink = @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=385038402&mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Dequeue or if necessary create a NoteCellView, then set its note to the note for the current row.
    static NSString *NoteCellIdentifier;    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        NoteCellIdentifier = @"NoteCellIdentifierP";
    }
    else {
        NoteCellIdentifier  = @"NoteCellIdentifierL";
    }
    
    NoteCellView *noteCell = (NoteCellView *)[tableView dequeueReusableCellWithIdentifier:NoteCellIdentifier];
    if (noteCell == nil) {
        noteCell = [[[NoteCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoteCellIdentifier orientation:self.interfaceOrientation] autorelease];
		noteCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	[self configureCell:noteCell atIndexPath:indexPath];
    
    return noteCell;
}

- (void)configureCell:(NoteCellView *)cell atIndexPath:(NSIndexPath *)indexPath {
	Note *note = (Note *)[fetchedResultsController objectAtIndexPath:indexPath];
    cell.note = note;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotePadViewController *notePadController = [[NotePadViewController alloc] initWithNibName:@"NotePadView" bundle:nil];
    notePadController.managedObjectContext = self.managedObjectContext;
    Note *note = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    notePadController.note = note;
    notePadController.title = note.notes;
    [self.navigationController pushViewController:notePadController animated:YES];
    [notePadController release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
	}   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }

	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
    [fetchRequest setFetchBatchSize:20];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
    
    NSError *error = nil;
    if (![fetchedResultsController performFetch:&error]) {
        error(@"An error occured retrieving fetched results. %@, %@", error, [error userInfo]);
        // Display an alert message if an error occurs
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Visual Notes failed to start! \n\nPlease exit the application by pressing the home button." 
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
	
	return fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	debug(@"controllerWillChangeContent");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	
    UITableView *tableView = self.tableView;
    
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
    [self saveManagedContext];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self setControllerTitle];
    [self.tableView endUpdates];
}

#pragma mark -
#pragma mark Utility methods

- (NSUInteger)getNoteCount {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext]];
    NSError *err;
    NSUInteger count = [managedObjectContext countForFetchRequest:request error:&err];
    if(count == NSNotFound) {
        count = 0;
    }
    [request release];
    return count;
}

- (void)saveManagedContext {
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            error(@"An error occured saving the managedObjectContext. %@, %@", error, [error userInfo]);
        } else {
            debug(@"Successfully saved managedObjectContext");
        }        
    }
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[fetchedResultsController release];
	[managedObjectContext release];
    [backgroundViewPortrait release];
    [backgroundViewLandscape release];
    [super dealloc];
}

@end