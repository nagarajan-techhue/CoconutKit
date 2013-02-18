//
//  CursorPointerInfoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorPointerInfoViewController.h"

@implementation CursorPointerInfoViewController

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

@end
