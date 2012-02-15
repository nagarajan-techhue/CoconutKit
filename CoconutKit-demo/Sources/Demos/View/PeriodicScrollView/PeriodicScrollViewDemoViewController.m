//
//  PeriodicScrollViewDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 06.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "PeriodicScrollViewDemoViewController.h"

@implementation PeriodicScrollViewDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.noneScrollView = nil;
    self.verticalScrollView = nil;
    self.horizontalScrollView = nil;
    self.bothScrollView = nil;
}

#pragma mark Accessors and mutators

@synthesize noneScrollView = m_noneScrollView;

@synthesize verticalScrollView = m_verticalScrollView;

@synthesize horizontalScrollView = m_horizontalScrollView;

@synthesize bothScrollView = m_bothScrollView;

#pragma mark View lifecycle

#if 0
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noneScrollView.contentSize = self.noneScrollView.frame.size;
    self.verticalScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.verticalScrollView.frame), 1000.f);
    self.horizontalScrollView.contentSize = CGSizeMake(800.f, CGRectGetHeight(self.horizontalScrollView.frame));
    self.bothScrollView.contentSize = CGSizeMake(1000.f, 1000.f);
}
#endif

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.noneScrollView.periodicity = HLSScrollViewPeriodicityNone;
    UIView *view1 = [[[UIView alloc] initWithFrame:CGRectMake(40.f, 40.f, 60.f, 60.f)] autorelease];
    view1.backgroundColor = [UIColor redColor];
    [self.noneScrollView addSubview:view1];
    self.noneScrollView.contentSize = self.noneScrollView.frame.size;
    
    self.verticalScrollView.periodicity = HLSScrollViewPeriodicityVertical;
    UIView *view2 = [[[UIView alloc] initWithFrame:CGRectMake(40.f, 40.f, 60.f, 60.f)] autorelease];
    view2.backgroundColor = [UIColor redColor];
    [self.verticalScrollView addSubview:view2];
    self.verticalScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.verticalScrollView.frame), 1000.f);
    
    self.horizontalScrollView.periodicity = HLSScrollViewPeriodicityHorizontal;
    UIView *view3 = [[[UIView alloc] initWithFrame:CGRectMake(40.f, 40.f, 60.f, 60.f)] autorelease];
    view3.backgroundColor = [UIColor redColor];
    [self.horizontalScrollView addSubview:view3];
    self.horizontalScrollView.contentSize = CGSizeMake(800.f, CGRectGetHeight(self.horizontalScrollView.frame));
    
    self.bothScrollView.periodicity = HLSScrollViewPeriodicityBoth;
    self.bothScrollView.contentSize = CGSizeMake(1000.f, 1000.f);
}


#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Periodic scroll view", @"Periodic scroll view");
}

@end
