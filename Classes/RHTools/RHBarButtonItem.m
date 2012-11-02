//
//  RHBarButtonItem.m
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

#import "RHBarButtonItem.h"

@interface RHBarButtonItem()
@property (nonatomic, copy) RHBarButtonItemBlock block;
@end

@implementation RHBarButtonItem
@synthesize block;

+(id)itemWithTitle:(NSString *)title block:(RHBarButtonItemBlock)_block {
    return [[self alloc] initWithTitle:title block:_block];
}

-(id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem block:(RHBarButtonItemBlock)_block {
	if (self=[super initWithBarButtonSystemItem:systemItem target:self action:@selector(tap:)]) {
		// http://stackoverflow.com/questions/6065963/do-i-have-to-retain-blocks-in-objective-c-for-ios
		[self setBlock:_block]; // copied by @property
	}
	return self;
}

-(id)initWithTitle:(NSString *)title block:(RHBarButtonItemBlock)_block {
 	if (self=[super initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(tap:)]) {
		// http://stackoverflow.com/questions/6065963/do-i-have-to-retain-blocks-in-objective-c-for-ios
		[self setBlock:_block];
	}
	return self;
}

-(void)tap:(id)sender {
	if (self.block) {
		self.block();
	}
}

@end