//
//  NSDate+formatter.m
//  Version: 0.1
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

#import "NSDate+formatter.h"

@implementation NSDate (formatter)

+(NSDateFormatter *)formatter {
    
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t oncePredicate;
	
    dispatch_once(&oncePredicate, ^{
        formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterMediumStyle];
		[formatter setTimeStyle:NSDateFormatterShortStyle];
		[formatter setDoesRelativeDateFormatting:YES];
    });
	
    return formatter;
}

+(double)localTimeZoneOffset {
    return [[NSTimeZone defaultTimeZone] secondsFromGMT]/3600;
}

-(NSString *)formatWithUTCTimeZone {
    return [self formatWithTimeZoneOffset:0];
}

-(NSString *)formatWithLocalTimeZone {
    NSDateFormatter *formatter = [NSDate formatter];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];    
    return [formatter stringFromDate:self];
}

-(NSString *)formatWithTimeZoneOffset:(NSTimeInterval)offset {
    NSDateFormatter *formatter = [NSDate formatter];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:offset]];
    return [formatter stringFromDate:self];
}

@end