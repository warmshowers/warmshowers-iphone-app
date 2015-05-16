//
//  LoginViewController.m
//  WS
//
//  Created by Christopher Meyer on 15/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

#import "LoginViewController.h"


@interface LoginViewController ()
@property (nonatomic, strong) NSLayoutConstraint *bottomConstraint;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.loginButton setType:BButtonTypePrimary];
    
    /* Create constraints explicitly.  Constraints are of the form "view1.attr1 = view2.attr2 * multiplier + constant"
     If your equation does not have a second view and attribute, use nil and NSLayoutAttributeNotAnAttribute.
     */
    /*
     +(instancetype)constraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
     */
    
    self.bottomConstraint = [NSLayoutConstraint
                             constraintWithItem:self.view
                             attribute:NSLayoutAttributeBottom
                             relatedBy:NSLayoutRelationEqual
                             toItem:self.contentView
                             attribute:NSLayoutAttributeBottom
                             multiplier:1.0f
                             constant:0];
    
    
    [self.view addConstraint:self.bottomConstraint];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    
    
  //  [self.contentView setBackgroundColor:[UIColor greenColor]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateView) name:UITextFieldTextDidBeginEditingNotification object:nil];
}

-(void)keyboardDidChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    self.bottomConstraint.constant = (self.view.height-keyboardFrame.origin.y);
    [self.view setNeedsUpdateConstraints];
    
    
    
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationOptions animationCurve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationCurve
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
    
}



@end
