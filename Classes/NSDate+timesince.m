//
//  NSDate+timesince.m
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

#import "NSDate+timesince.h"

@implementation NSDate (timesince)

-(NSString *)timesince {
	return [self timesinceWithDepth:2];
}

-(NSString *)timesinceWithDepth:(int)depth {
    return [self timesinceDate:[NSDate date] withDepth:depth];
}

-(NSString *)timesinceDate:(NSDate *)date withDepth:(int)depth {
	// This should idealy be cached and not reconstructed on each use.  However, Obj-C categories
	// do not allow class variables to be defined.
	
    NSArray *units_singular = [NSArray arrayWithObjects:
							   NSLocalizedStringFromTable(@"year", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"month", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"week", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"day", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"hour", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"minute", @"NSDate+timesince", nil),
							   // NSLocalizedStringFromTable(@"second", @"NSDate+timesince", nil),
							   nil];
	
    NSArray *units_plural	= [NSArray arrayWithObjects:
							   NSLocalizedStringFromTable(@"years", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"months", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"weeks", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"days", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"hours", @"NSDate+timesince", nil),
							   NSLocalizedStringFromTable(@"minutes", @"NSDate+timesince", nil),
							   // NSLocalizedStringFromTable(@"seconds", @"NSDate+timesince", nil),
							   nil];
	
	NSArray *values = [NSArray arrayWithObjects:
					   [NSNumber numberWithInt:31556926],
					   [NSNumber numberWithInt:2629744],
					   [NSNumber numberWithInt:604800],
					   [NSNumber numberWithInt:86400],
					   [NSNumber numberWithInt:3600],
					   [NSNumber numberWithInt:60],
					   [NSNumber numberWithInt:1],
					   nil];
	
	int delta = abs([self timeIntervalSinceDate:date]);
	
	if ( delta < 60 ) {
        // just return "seconds" if the difference is less than a minute
        // return [units_plural lastObject];
		// return NSLocalizedStringFromTable(@"less than a minute", @"NSDate+timesince", nil);
		return [NSString stringWithFormat:@"0 %@", [units_plural lastObject]];
    }
	
    NSMutableArray *comp = [NSMutableArray array];
	
    for(int i=0; i < [units_singular count]; i++) {
		
		int unit = [[values objectAtIndex:i] intValue];
        int v = (int)(delta/unit);
		
        delta = delta % unit;
		
        if ( (v == 0) || (depth == 0) ) {
            // do nothing
        } else {
			if (v == 1) {
				[comp addObject:[NSString stringWithFormat:@"%i %@", v, [units_singular objectAtIndex:i]]];
            } else {
				[comp addObject:[NSString stringWithFormat:@"%i %@", v, [units_plural objectAtIndex:i]]];
			}
			
			depth--;
        }
    }
	
    return [comp componentsJoinedByString:@", "];
}

@end