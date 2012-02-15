//
//  HLSPeriodicScrollView.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 03.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSPeriodicScrollView.h"

#import "HLSFloat.h"
#import "HLSLogger.h"

const CGFloat kMarginFactor = 0.25f;            // Must be <= 1.f

@implementation HLSPeriodicScrollView

#pragma mark Accessors and mutators

@synthesize periodicity = m_periodicity;

#pragma mark Layout

// TODO: Hide scroll indicators. Remove code to ignore them (useless)

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // If scrolling too far away to the left / right, recenter to create illusion of infinite scrolling
    if (floatlt(self.contentOffset.x, kMarginFactor * self.contentSize.width)
            || floatgt(self.contentOffset.x, (1.f - kMarginFactor) * self.contentSize.width)) {
        CGFloat deltaX = self.contentSize.width / 2.f - (self.contentOffset.x + CGRectGetWidth(self.frame) / 2.f);
        self.contentOffset = CGPointMake(self.contentOffset.x + deltaX, self.contentOffset.y);
        for (UIView *subview in self.subviews) {
            subview.center = CGPointMake(subview.center.x + deltaX, subview.center.y);
        }
    }
}

@end
