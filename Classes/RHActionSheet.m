//
//  RHActionSheet.m
//  Version: 0.2
//
//  Copyright (C) 2012 by Christopher Meyer
//  http://schwiiz.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "RHActionSheet.h"

@interface RHActionSheet()
@property (nonatomic, strong) NSMutableDictionary *actions;
@end

@implementation RHActionSheet
@synthesize actions;

+(RHActionSheet *)actionSheetWithTitle:(NSString *)title {
	return [[RHActionSheet alloc] initWithTitle:title];
}

-(id)init {
	if (self=[super init]) {
		self.delegate = self;
		self.actions = [NSMutableDictionary dictionary];
	}
	
	return self;
}

-(id)initWithTitle:(NSString *)title {
	if (self=[self init]) {
		self.title = title;
	}
	
	return self;
}

-(NSInteger)addButtonWithTitle:(NSString *)title block:(RHActionSheetBlock)block {
	NSInteger index = [self addButtonWithTitle:title];
	NSNumber *key = [NSNumber numberWithInteger:index];
	
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

-(void)dismiss {
	[self dismissAnimate:YES];
}

-(void)dismissAnimate:(BOOL)animate {
	[self dismissWithClickedButtonIndex:[self cancelButtonIndex] animated:animate];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSNumber *key = [NSNumber numberWithInteger:buttonIndex];
	RHActionSheetBlock block = [self.actions objectForKey:key];
	
	if (block) {
		block();
	}
	
	// This line prevents a retain cycle if alert is referenced within the block.
	self.actions = nil;
}

@end