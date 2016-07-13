//
//  NoteCellView.m
//  VisualNotes
//
//  Created by Richard Lucas on 4/3/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "NoteCellView.h"

#pragma mark -
#pragma mark SubviewFrames category

@interface NoteCellView (SubviewFrames)
- (CGRect)_backgroundFrame;
- (CGRect)_thumbnailFrame;
- (CGRect)_noteLabelFrame;
- (CGRect)_dateLabelFrame;
@end

#pragma mark -
#pragma mark NoteCellView implementation

@implementation NoteCellView

@synthesize note, noteLabel, dateLabel, thumbnail, defaultThumbnail;

#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier orientation:(UIInterfaceOrientation)orientation {
    
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
        self.defaultThumbnail = [UIImage imageNamed:@"text-thumbnail"];
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero]; 
            UIImage *cellBackground = [UIImage imageNamed:@"cell-background-landscape"];
            ((UIImageView *)self.backgroundView).image = cellBackground;
        } else {
            self.backgroundView = [[UIImageView alloc] initWithFrame:CGRectZero]; 
            UIImage *cellBackground = [UIImage imageNamed:@"cell-background"];
            ((UIImageView *)self.backgroundView).image = cellBackground;
        }
        
        thumbnail = [[UIImageView alloc] initWithFrame:CGRectZero];
		thumbnail.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:thumbnail];
        
        dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [dateLabel setFont:[UIFont systemFontOfSize:10.0]];
        [dateLabel setBackgroundColor: [UIColor clearColor]];
        [dateLabel setTextColor:[UIColor darkGrayColor]];
        [dateLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:dateLabel];
        
        noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [noteLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [noteLabel setBackgroundColor: [UIColor clearColor]];
        [noteLabel setTextColor:[UIColor blackColor]];
        [noteLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:noteLabel];
        
    }
    return self;
}

#pragma mark -
#pragma mark Laying out subviews

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.backgroundView setFrame:[self _backgroundFrame]];
    [thumbnail setFrame:[self _thumbnailFrame]];
    [noteLabel setFrame:[self _noteLabelFrame]];
    [dateLabel setFrame:[self _dateLabelFrame]];
}

#define IMAGE_SIZE          50.0
#define TEXT_LEFT_MARGIN    18.0
#define TEXT_RIGHT_MARGIN   15.0

- (CGRect)_backgroundFrame {
    return CGRectMake(IMAGE_SIZE, 0.0, self.bounds.size.width - IMAGE_SIZE, self.contentView.bounds.size.height);
}

- (CGRect)_thumbnailFrame {
    return CGRectMake(0.0, 0.0, IMAGE_SIZE, IMAGE_SIZE);
}

- (CGRect)_noteLabelFrame {
    return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 8.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_RIGHT_MARGIN * 2, 16.0);
}

- (CGRect)_dateLabelFrame {
    return CGRectMake(IMAGE_SIZE + TEXT_LEFT_MARGIN, 30.0, self.contentView.bounds.size.width - IMAGE_SIZE - TEXT_LEFT_MARGIN, 16.0);
}

#pragma mark -
#pragma mark Note set accessor

- (void)setNote:(Note *)newNote {
    if (newNote != note) {
        [note release];
        note = [newNote retain];
	}
    // Set the note label
    noteLabel.text = [note title];
    
    // Set the date label
    dateLabel.text = [note subtitle];
    
    // Set the thumbnail
    if (note.thumbnail == nil) {
        thumbnail.image = self.defaultThumbnail;
    } else {
        thumbnail.image = note.thumbnail;
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [noteLabel release];
    [dateLabel release];
    [thumbnail release];
    [defaultThumbnail release];
    [super dealloc];
}

@end
