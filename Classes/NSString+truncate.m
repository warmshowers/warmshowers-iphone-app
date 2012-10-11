// http://iphonedevelopertips.com/cocoa/truncate-an-nsstring-and-append-an-ellipsis-respecting-the-font-size.html

#import "NSString+truncate.h"

#define ellipsis @"…"

@implementation NSString (truncate)

-(NSString *)truncateToLength:(int)charLength {
	if ( self.length > charLength ) {
		NSRange range = {0, charLength-ellipsis.length};
		return [[self substringWithRange:range] stringByAppendingFormat:ellipsis];
	} else {
		return self;
	}
}

-(NSString *)trim {
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end