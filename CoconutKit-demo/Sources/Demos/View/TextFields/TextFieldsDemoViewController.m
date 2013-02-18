//
//  TextFieldsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "TextFieldsDemoViewController.h"

@interface TextFieldsDemoViewController ()

@property (nonatomic, weak) IBOutlet HLSTextField *textField1;
@property (nonatomic, weak) IBOutlet HLSTextField *textField2;
@property (nonatomic, weak) IBOutlet HLSTextField *textField3;
@property (nonatomic, weak) IBOutlet HLSTextField *textField4;

@end

@implementation TextFieldsDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textField1.delegate = self;
    self.textField2.delegate = self;
    self.textField3.delegate = self;
    self.textField4.delegate = self;
    
    self.textField2.resigningFirstResponderOnTap = NO;
}

#pragma mark UITextFieldDelegate protocol implementation

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];

    self.title = NSLocalizedString(@"Text fields", nil);
}

@end
