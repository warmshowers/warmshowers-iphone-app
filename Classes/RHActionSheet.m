//
//  RHActionSheet.m
//
//  Created by Christopher Meyer on 9/24/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//
//  Inspired by DTActionSheet/DTFoundation from Cocoanetics - https://github.com/Cocoanetics/DTFoundation

#import "RHActionSheet.h"

@interface RHActionSheet()

@property (nonatomic, strong) NSMutableDictionary *actions;

+(NSNumber *)keyForIndex:(NSInteger)index;

@end

@implementation RHActionSheet
@synthesize actions;

+(NSNumber *)keyForIndex:(NSInteger)index {
	return [NSNumber numberWithInt:index];
}

-(id)init {
	if (self=[super init]) {
		self.delegate = self;
	}
	
	return self;
}


-(id)initWithTitle:(NSString *)title {
	if (self=[self init]) {
		self.title = title;
	}
	
	return self;
}

-(NSMutableDictionary *)actions {
	if (actions == nil) {
		self.actions = [NSMutableDictionary dictionary];
	}
	
	return actions;
}

-(NSInteger)addButtonWithTitle:(NSString *)title block:(RHActionSheetBlock)block {
	NSInteger index = [self addButtonWithTitle:title];
	NSNumber *key = [RHActionSheet keyForIndex:index];
	
	if (block) {
		[self.actions setObject:[block copy] forKey:key];
	}
	
	return index;
}

-(NSInteger)addDestructiveButtonWithTitle:(NSString *)title block:(RHActionSheetBlock)block {
	NSInteger index = [self addButtonWithTitle:title block:block];
	[self setDestructiveButtonIndex:index];
	
	return index;
}

-(NSInteger)addCancelButtonWithTitle:(NSString *)title {
	NSInteger index = [self addButtonWithTitle:title];
	[self setCancelButtonIndex:index];
	return index;
}

-(NSInteger)addCancelButton {
	return [self addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	
	NSNumber *key = [RHActionSheet keyForIndex:buttonIndex];
	RHActionSheetBlock block = [self.actions objectForKey:key];
	
	if (block) {
		block();
	}
	
}


@end
