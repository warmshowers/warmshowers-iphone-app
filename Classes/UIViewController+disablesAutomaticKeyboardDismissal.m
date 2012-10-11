//
//  UIViewController+disablesAutomaticKeyboardDismissal.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 4/21/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "UIViewController+disablesAutomaticKeyboardDismissal.h"

@implementation UIViewController (disablesAutomaticKeyboardDismissal)


// http://developer.apple.com/library/ios/#documentation/uikit/reference/UIViewController_Class/Reference/Reference.html#//apple_ref/occ/instm/UIViewController/disablesAutomaticKeyboardDismissal
-(BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}


// Required iOS6 to allow all orientations
//-(NSUInteger)supportedInterfaceOrientations {
 //   return UIInterfaceOrientationMaskAll;
// }


@end
