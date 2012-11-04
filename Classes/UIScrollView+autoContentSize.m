//
//  UIScrollView+autoContentSize.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 1/14/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "UIScrollView+autoContentSize.h"

@implementation UIScrollView (autoContentSize)


-(void)autoContentSize {
	
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	CGFloat scrollViewHeight = 0.0f;
	for (UIView* view in self.subviews) {
		if (!view.hidden) {
			CGFloat y = view.frame.origin.y;
			CGFloat h = view.frame.size.height;			
			scrollViewHeight = MAX(scrollViewHeight, h+y);
		}
	}
	
	[self setContentSize:(CGSizeMake(self.frame.size.width, scrollViewHeight+10))];
	self.showsHorizontalScrollIndicator = YES;
	self.showsVerticalScrollIndicator = YES;
}

@end