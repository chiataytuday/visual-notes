//
//  VisualNotesAppDelegate.m
//  VisualNotes
//
//  Created by Richard Lucas on 2/21/10.
//  Copyright lucasweb 2010. All rights reserved.
//

#import "VisualNotesAppDelegate.h"
#import "NoteListViewController.h"
#import "LocationManager.h"
#import "LogManager.h"


@implementation VisualNotesAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (void)awakeFromNib {    
    
    NoteListViewController *noteListViewController = (NoteListViewController *)[navigationController topViewController];
    noteListViewController.managedObjectContext = self.managedObjectContext;}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:@"NO" forKey:@"enableDataDetectors"];
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
    
    // Sets a black background when transtioning between views
    UIView *blackView = [[UIView alloc]initWithFrame: CGRectMake(0, 0, 320, 480)];
    blackView.backgroundColor = [UIColor blackColor];
    [window addSubview: blackView];
    [window bringSubviewToFront: blackView];
    [blackView release];
    
    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    return YES;
}

/*
 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
 */
- (void)applicationWillResignActive:(UIApplication *)application {
}

/*
 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
 If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
 */
- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
                error(@"Unable to save the managedObjectContext before the background task expired");
            }
        });
    }];
    
    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        if (managedObjectContext_ != nil) {
            if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
                error(@"An error occured saving the managedObjectContext. %@, %@", error, [error userInfo]);
            } else {
                debug(@"Successfully saved managedObjectContext");
            }

        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (bgTask != UIBackgroundTaskInvalid)
            {
                [app endBackgroundTask:bgTask];
                bgTask = UIBackgroundTaskInvalid;
            }
        });
    });
}

/*
 Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
}

/*
 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application {
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext_ != nil) {
        if ([managedObjectContext_ hasChanges] && ![managedObjectContext_ save:&error]) {
            error(@"An error occured saving the managedObjectContext. %@, %@", error, [error userInfo]);
        } else {
            debug(@"Successfully saved managedObjectContext");
        }
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"VisualNotes" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"VisualNotes.sqlite"]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        error(@"An error occured adding the persistentStoreCoordinator. %@, %@", error, [error userInfo]);
		// Display an alert message if an error occurs
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Visual Notes failed to start! \n\nPlease exit the application by pressing the home button." 
                                                       delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [alert show];
        [alert release];
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

/*
 Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
 */
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [navigationController release];
    [window release];
    [super dealloc];
}


@end
