// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.m instead.

#import "_Thread.h"

const struct ThreadAttributes ThreadAttributes = {
	.count = @"count",
	.is_new = @"is_new",
	.subject = @"subject",
	.threadid = @"threadid",
};

const struct ThreadRelationships ThreadRelationships = {
	.messages = @"messages",
	.user = @"user",
};

@implementation ThreadID
@end

@implementation _Thread

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Thread" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Thread";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:moc_];
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
	if ([key isEqualToString:@"is_newValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"is_new"];
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

@dynamic is_new;

- (BOOL)is_newValue {
	NSNumber *result = [self is_new];
	return [result boolValue];
}

- (void)setIs_newValue:(BOOL)value_ {
	[self setIs_new:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIs_newValue {
	NSNumber *result = [self primitiveIs_new];
	return [result boolValue];
}

- (void)setPrimitiveIs_newValue:(BOOL)value_ {
	[self setPrimitiveIs_new:[NSNumber numberWithBool:value_]];
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

@dynamic user;

@end

