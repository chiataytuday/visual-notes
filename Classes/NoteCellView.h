//
//  NoteCellView.h
//  VisualNotes
//
//  Created by Richard Lucas on 4/3/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Note.h"


@interface NoteCellView : UITableViewCell {
    Note *note;
    UILabel *noteLabel;
    UILabel *dateLabel;
    UIImageView *thumbnail;
    UIImage *defaultThumbnail;
}

@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) UILabel *noteLabel;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UIImageView *thumbnail;
@property (nonatomic, retain) UIImage *defaultThumbnail;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier orientation:(UIInterfaceOrientation)orientation;
- (void)setNote:(Note *)newNote; 

@end
