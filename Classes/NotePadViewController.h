//
//  NotePadViewController.h
//  VisualNotes
//
//  Created by Richard Lucas on 3/7/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Note.h"
#import "CustomUIScrollView.h"

@interface NotePadViewController : UIViewController <UITextViewDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate> {
    Note *note;
    UIView *notePadView;
    CustomUIScrollView *imageScrollView;
    UITextView *textView;
    UIBarButtonItem *noteFlipBarButton;
    UIView *noteFlipButtonCustomView;
    UIView *textButtonView;
    UIView *imageButtonView;
    UIToolbar *toolbar;
    UIImageView *notepaper;
    NSManagedObjectContext *managedObjectContext;
    BOOL didZoom;
    BOOL fullScreen;
    
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) UIView *notePadView;
@property (nonatomic, retain) CustomUIScrollView *imageScrollView;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIBarButtonItem *noteFlipBarButton;
@property (nonatomic, retain) UIView *noteFlipButtonCustomView;
@property (nonatomic, retain) UIView *textButtonView;
@property (nonatomic, retain) UIView *imageButtonView;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIImageView *notepaper;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end