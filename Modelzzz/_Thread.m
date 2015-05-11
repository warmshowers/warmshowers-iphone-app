// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.m instead.

#import "_Thread.h"

const struct ThreadAttributes ThreadAttributes = {
	.count = @"count",
	.subject = @"subject",
	.threadid = @"threadid",
};

const struct ThreadRelationships ThreadRelationships = {
	.messages = @"messages",
	.participants = @"participants",
};

@implementation ThreadID
@end

@implementation _Thread

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ThreadEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ThreadEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ThreadEntity" inManagedObjectContext:moc_];
}

- (ThreadID*)objectID {
	return (ThreadID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"countValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"count"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"threadidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"threadid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic count;

- (int32_t)countValue {
	NSNumber *result = [self count];
	return [result intValue];
}

- (void)setCountValue:(int32_t)value_ {
	[self setCount:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveCountValue {
	NSNumber *result = [self primitiveCount];
	return [result intValue];
}

- (void)setPrimitiveCountValue:(int32_t)value_ {
	[self setPrimitiveCount:[NSNumber numberWithInt:value_]];
}

@dynamic subject;

@dynamic threadid;

- (int32_t)threadidValue {
	NSNumber *result = [self threadid];
	return [result intValue];
}

- (void)setThreadidValue:(int32_t)value_ {
	[self setThreadid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveThreadidValue {
	NSNumber *result = [self primitiveThreadid];
	return [result intValue];
}

- (void)setPrimitiveThreadidValue:(int32_t)value_ {
	[self setPrimitiveThreadid:[NSNumber numberWithInt:value_]];
}

@dynamic messages;

- (NSMutableSet*)messagesSet {
	[self willAccessValueForKey:@"messages"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"messages"];

	[self didAccessValueForKey:@"messages"];
	return result;
}

@dynamic participants;

- (NSMutableSet*)participantsSet {
	[self willAccessValueForKey:@"participants"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"participants"];

	[self didAccessValueForKey:@"participants"];
	return result;
}

@end

