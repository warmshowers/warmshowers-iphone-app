// http://iphonedevelopertips.com/cocoa/truncate-an-nsstring-and-append-an-ellipsis-respecting-the-font-size.html

@interface NSString (truncate)

-(NSString *)truncateToLength:(int)charLength;
-(NSString *)trim;

@end