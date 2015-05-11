// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Feedback.m instead.

#import "_Feedback.h"

const struct FeedbackAttributes FeedbackAttributes = {
	.body = @"body",
	.date = @"date",
	.fullname = @"fullname",
	.hostOrGuest = @"hostOrGuest",
	.nid = @"nid",
};

const struct FeedbackRelationships FeedbackRelationships = {
	.host = @"host",
};

@implementation FeedbackID
@end

@implementation _Feedback

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"FeedbackEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"FeedbackEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"FeedbackEntity" inManagedObjectContext:moc_];
}

- (FeedbackID*)objectID {
	return (FeedbackID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"nidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"nid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic body;

@dynamic date;

@dynamic fullname;

@dynamic hostOrGuest;

@dynamic nid;

- (int32_t)nidValue {
	NSNumber *result = [self nid];
	return [result intValue];
}

- (void)setNidValue:(int32_t)value_ {
	[self setNid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveNidValue {
	NSNumber *result = [self primitiveNid];
	return [result intValue];
}

- (void)setPrimitiveNidValue:(int32_t)value_ {
	[self setPrimitiveNid:[NSNumber numberWithInt:value_]];
}

@dynamic host;

@end

