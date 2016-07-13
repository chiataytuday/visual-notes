//
//  NoteListViewController.h
//  VisualNotes
//
//  Created by Richard Lucas on 2/21/10.
//  Copyright lucasweb 2010. All rights reserved.
//

#import "NotePadViewController.h"

@interface NoteListViewController : UITableViewController <UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
    UIImageView *backgroundViewPortrait;
    UIImageView *backgroundViewLandscape;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) UIImageView *backgroundViewPortrait;
@property (nonatomic, retain) UIImageView *backgroundViewLandscape;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
