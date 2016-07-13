//
//  CustomUIScrollView.m
//  VisualNotes
//
//  Created by Richard Lucas on 9/5/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "CustomUIScrollView.h"


@implementation CustomUIScrollView

#pragma mark -
#pragma mark Initialisers

- (id)initWithChildView:(UIView *)aChildView {
	if ((self = [super init])) {
        [self setChildView: aChildView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)aFrame andChildView:(UIView *)aChildView  {
    if ((self = [super initWithFrame:aFrame])) {
        [self setChildView: aChildView];
    }
    return self;
}


#pragma mark -
#pragma mark Accessors


- (UIView *)childView {
    return [[childView retain] autorelease]; 
}


-(void)setChildView:(UIView *)aChildView {
	if (childView != aChildView) {
		[childView removeFromSuperview];
        [childView release];
        childView = [aChildView retain];
		[super addSubview:childView];
		[self setContentOffset:CGPointZero];
    }
}


#pragma mark -
#pragma mark UIScrollView


// Rather than the default behaviour of a {0,0} offset when an image is too small to fill the UIScrollView we're going to return an offset that centres the image in the UIScrollView instead.
- (void)setContentOffset:(CGPoint)anOffset {
	if(childView != nil) {
		CGSize zoomViewSize = childView.frame.size;
		CGSize scrollViewSize = self.bounds.size;
		
		if(zoomViewSize.width < scrollViewSize.width) {
			anOffset.x = -(scrollViewSize.width - zoomViewSize.width) / 2.0;
		}
		
		if(zoomViewSize.height < scrollViewSize.height) {
			anOffset.y = -(scrollViewSize.height - zoomViewSize.height) / 2.0;
		}
	}
	
	super.contentOffset = anOffset;
}


- (void)dealloc {
	[childView release], childView = nil;

    [super dealloc];
}

@end
