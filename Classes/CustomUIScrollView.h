//
//  CustomUIScrollView.h
//  VisualNotes
//
//  Created by Richard Lucas on 9/5/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIScrollView : UIScrollView {
	UIView *childView;
}

@property (nonatomic, retain) IBOutlet UIView *childView;

- (id)initWithChildView:(UIView *)aChildView;
- (id)initWithFrame:(CGRect)aFrame andChildView:(UIView *)aChildView;

@end
