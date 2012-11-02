//
//  RHAlertView.m
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

#import "RHAlertView.h"

@interface RHAlertView()
@property (nonatomic, strong) NSMutableDictionary *actions;
@end

@implementation RHAlertView
@synthesize actions;

+(RHAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message {
	return [[self alloc] initWithTitle:title message:message];
}

+(RHAlertView *)alertWithOKButtonWithTitle:(NSString *)title message:(NSString *)message {
	RHAlertView *alert = [self alertWithTitle:title message:message];
	[alert addOKButton];
	return alert;
}

-(id)init {
	if (self=[super init]) {
		self.delegate = self;
		self.actions = [NSMutableDictionary dictionary];
	}
	return self;
}

-(id)initWithTitle:(NSString *)title message:(NSString *)message {
	if (self=[self init]) {
		self.title = title;
		self.message = message;
	}
	return self;
}

-(NSInteger)addButtonWithTitle:(NSString *)title block:(RHAlertBlock)block {
	NSInteger index = [self addButtonWithTitle:title];
	if (block) {
		NSNumber *key = [NSNumber numberWithInt:index];
		[self.actions setObject:[block copy] forKey:key];
	}
	return index;
}

-(NSInteger)addOKButton {
	return [self addButtonWithTitle:NSLocalizedString(@"OK", nil) block:nil];
}

-(NSInteger)addCancelButton {
	return [self addCancelButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
}

-(NSInteger)addCancelButtonWithTitle:(NSString *)title {
	NSInteger index = [self addButtonWithTitle:title];
	[self setCancelButtonIndex:index];
	return index;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSNumber *key = [NSNumber numberWithInt:buttonIndex];
	RHAlertBlock block = [self.actions objectForKey:key];
	
	if (block) {
		block();
	}
	
	// This line prevents a retain cycle if alert is referenced within the block.
	self.actions = nil;
}

@end