// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.m instead.

#import "_Message.h"

const struct MessageAttributes MessageAttributes = {
	.body = @"body",
	.mid = @"mid",
};

const struct MessageRelationships MessageRelationships = {
	.author = @"author",
	.thread = @"thread",
};

@implementation MessageID
@end

@implementation _Message

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Message";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Message" inManagedObjectContext:moc_];
}

- (MessageID*)objectID {
	return (MessageID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"midValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic body;

@dynamic mid;

- (int32_t)midValue {
	NSNumber *result = [self mid];
	return [result intValue];
}

- (void)setMidValue:(int32_t)value_ {
	[self setMid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMidValue {
	NSNumber *result = [self primitiveMid];
	return [result intValue];
}

- (void)setPrimitiveMidValue:(int32_t)value_ {
	[self setPrimitiveMid:[NSNumber numberWithInt:value_]];
}

@dynamic author;

@dynamic thread;

@end

