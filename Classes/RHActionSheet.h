//
//  RHActionSheet.h
//
//  Created by Christopher Meyer on 9/24/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//
//  Inspired by DTActionSheet/DTFoundation from Cocoanetics - https://github.com/Cocoanetics/DTFoundation

typedef void (^RHActionSheetBlock)(void);

@interface RHActionSheet : UIActionSheet<UIActionSheetDelegate>

-(id)initWithTitle:(NSString *)title;
-(NSInteger)addButtonWithTitle:(NSString *)title block:(RHActionSheetBlock)block;
-(NSInteger)addDestructiveButtonWithTitle:(NSString *)title block:(RHActionSheetBlock)block;
-(NSInteger)addCancelButtonWithTitle:(NSString *)title;
-(NSInteger)addCancelButton;

@end