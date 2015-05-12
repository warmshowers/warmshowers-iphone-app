// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Host.m instead.

#import "_Host.h"

const struct HostAttributes HostAttributes = {
	.bed = @"bed",
	.bikeshop = @"bikeshop",
	.campground = @"campground",
	.city = @"city",
	.comments = @"comments",
	.country = @"country",
	.distance = @"distance",
	.favourite = @"favourite",
	.food = @"food",
	.fullname = @"fullname",
	.homephone = @"homephone",
	.hostid = @"hostid",
	.kitchenuse = @"kitchenuse",
	.last_login = @"last_login",
	.last_updated = @"last_updated",
	.last_updated_details = @"last_updated_details",
	.latitude = @"latitude",
	.laundry = @"laundry",
	.lawnspace = @"lawnspace",
	.longitude = @"longitude",
	.maxcyclists = @"maxcyclists",
	.member_since = @"member_since",
	.mobilephone = @"mobilephone",
	.motel = @"motel",
	.name = @"name",
	.notcurrentlyavailable = @"notcurrentlyavailable",
	.postal_code = @"postal_code",
	.preferred_notice = @"preferred_notice",
	.province = @"province",
	.sag = @"sag",
	.shower = @"shower",
	.storage = @"storage",
	.street = @"street",
};

const struct HostRelationships HostRelationships = {
	.feedback = @"feedback",
	.message = @"message",
	.thread = @"thread",
};

@implementation HostID
@end

@implementation _Host

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Host" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Host";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Host" inManagedObjectContext:moc_];
}

- (HostID*)objectID {
	return (HostID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"bedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"distanceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"distance"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"favouriteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"favourite"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"foodValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"food"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"hostidValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"hostid"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"kitchenuseValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"kitchenuse"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"laundryValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"laundry"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"lawnspaceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lawnspace"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"maxcyclistsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"maxcyclists"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"notcurrentlyavailableValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"notcurrentlyavailable"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"sagValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sag"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"showerValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"shower"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"storageValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"storage"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic bed;

- (BOOL)bedValue {
	NSNumber *result = [self bed];
	return [result boolValue];
}

- (void)setBedValue:(BOOL)value_ {
	[self setBed:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBedValue {
	NSNumber *result = [self primitiveBed];
	return [result boolValue];
}

- (void)setPrimitiveBedValue:(BOOL)value_ {
	[self setPrimitiveBed:[NSNumber numberWithBool:value_]];
}

@dynamic bikeshop;

@dynamic campground;

@dynamic city;

@dynamic comments;

@dynamic country;

@dynamic distance;

- (double)distanceValue {
	NSNumber *result = [self distance];
	return [result doubleValue];
}

- (void)setDistanceValue:(double)value_ {
	[self setDistance:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveDistanceValue {
	NSNumber *result = [self primitiveDistance];
	return [result doubleValue];
}

- (void)setPrimitiveDistanceValue:(double)value_ {
	[self setPrimitiveDistance:[NSNumber numberWithDouble:value_]];
}

@dynamic favourite;

- (BOOL)favouriteValue {
	NSNumber *result = [self favourite];
	return [result boolValue];
}

- (void)setFavouriteValue:(BOOL)value_ {
	[self setFavourite:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFavouriteValue {
	NSNumber *result = [self primitiveFavourite];
	return [result boolValue];
}

- (void)setPrimitiveFavouriteValue:(BOOL)value_ {
	[self setPrimitiveFavourite:[NSNumber numberWithBool:value_]];
}

@dynamic food;

- (BOOL)foodValue {
	NSNumber *result = [self food];
	return [result boolValue];
}

- (void)setFoodValue:(BOOL)value_ {
	[self setFood:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFoodValue {
	NSNumber *result = [self primitiveFood];
	return [result boolValue];
}

- (void)setPrimitiveFoodValue:(BOOL)value_ {
	[self setPrimitiveFood:[NSNumber numberWithBool:value_]];
}

@dynamic fullname;

@dynamic homephone;

@dynamic hostid;

- (int32_t)hostidValue {
	NSNumber *result = [self hostid];
	return [result intValue];
}

- (void)setHostidValue:(int32_t)value_ {
	[self setHostid:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveHostidValue {
	NSNumber *result = [self primitiveHostid];
	return [result intValue];
}

- (void)setPrimitiveHostidValue:(int32_t)value_ {
	[self setPrimitiveHostid:[NSNumber numberWithInt:value_]];
}

@dynamic kitchenuse;

- (BOOL)kitchenuseValue {
	NSNumber *result = [self kitchenuse];
	return [result boolValue];
}

- (void)setKitchenuseValue:(BOOL)value_ {
	[self setKitchenuse:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveKitchenuseValue {
	NSNumber *result = [self primitiveKitchenuse];
	return [result boolValue];
}

- (void)setPrimitiveKitchenuseValue:(BOOL)value_ {
	[self setPrimitiveKitchenuse:[NSNumber numberWithBool:value_]];
}

@dynamic last_login;

@dynamic last_updated;

@dynamic last_updated_details;

@dynamic latitude;

- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
}

@dynamic laundry;

- (BOOL)laundryValue {
	NSNumber *result = [self laundry];
	return [result boolValue];
}

- (void)setLaundryValue:(BOOL)value_ {
	[self setLaundry:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLaundryValue {
	NSNumber *result = [self primitiveLaundry];
	return [result boolValue];
}

- (void)setPrimitiveLaundryValue:(BOOL)value_ {
	[self setPrimitiveLaundry:[NSNumber numberWithBool:value_]];
}

@dynamic lawnspace;

- (BOOL)lawnspaceValue {
	NSNumber *result = [self lawnspace];
	return [result boolValue];
}

- (void)setLawnspaceValue:(BOOL)value_ {
	[self setLawnspace:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveLawnspaceValue {
	NSNumber *result = [self primitiveLawnspace];
	return [result boolValue];
}

- (void)setPrimitiveLawnspaceValue:(BOOL)value_ {
	[self setPrimitiveLawnspace:[NSNumber numberWithBool:value_]];
}

@dynamic longitude;

- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}

@dynamic maxcyclists;

- (int32_t)maxcyclistsValue {
	NSNumber *result = [self maxcyclists];
	return [result intValue];
}

- (void)setMaxcyclistsValue:(int32_t)value_ {
	[self setMaxcyclists:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveMaxcyclistsValue {
	NSNumber *result = [self primitiveMaxcyclists];
	return [result intValue];
}

- (void)setPrimitiveMaxcyclistsValue:(int32_t)value_ {
	[self setPrimitiveMaxcyclists:[NSNumber numberWithInt:value_]];
}

@dynamic member_since;

@dynamic mobilephone;

@dynamic motel;

@dynamic name;

@dynamic notcurrentlyavailable;

- (BOOL)notcurrentlyavailableValue {
	NSNumber *result = [self notcurrentlyavailable];
	return [result boolValue];
}

- (void)setNotcurrentlyavailableValue:(BOOL)value_ {
	[self setNotcurrentlyavailable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNotcurrentlyavailableValue {
	NSNumber *result = [self primitiveNotcurrentlyavailable];
	return [result boolValue];
}

- (void)setPrimitiveNotcurrentlyavailableValue:(BOOL)value_ {
	[self setPrimitiveNotcurrentlyavailable:[NSNumber numberWithBool:value_]];
}

@dynamic postal_code;

@dynamic preferred_notice;

@dynamic province;

@dynamic sag;

- (BOOL)sagValue {
	NSNumber *result = [self sag];
	return [result boolValue];
}

- (void)setSagValue:(BOOL)value_ {
	[self setSag:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSagValue {
	NSNumber *result = [self primitiveSag];
	return [result boolValue];
}

- (void)setPrimitiveSagValue:(BOOL)value_ {
	[self setPrimitiveSag:[NSNumber numberWithBool:value_]];
}

@dynamic shower;

- (BOOL)showerValue {
	NSNumber *result = [self shower];
	return [result boolValue];
}

- (void)setShowerValue:(BOOL)value_ {
	[self setShower:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveShowerValue {
	NSNumber *result = [self primitiveShower];
	return [result boolValue];
}

- (void)setPrimitiveShowerValue:(BOOL)value_ {
	[self setPrimitiveShower:[NSNumber numberWithBool:value_]];
}

@dynamic storage;

- (BOOL)storageValue {
	NSNumber *result = [self storage];
	return [result boolValue];
}

- (void)setStorageValue:(BOOL)value_ {
	[self setStorage:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStorageValue {
	NSNumber *result = [self primitiveStorage];
	return [result boolValue];
}

- (void)setPrimitiveStorageValue:(BOOL)value_ {
	[self setPrimitiveStorage:[NSNumber numberWithBool:value_]];
}

@dynamic street;

@dynamic feedback;

- (NSMutableSet*)feedbackSet {
	[self willAccessValueForKey:@"feedback"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"feedback"];

	[self didAccessValueForKey:@"feedback"];
	return result;
}

@dynamic message;

- (NSMutableSet*)messageSet {
	[self willAccessValueForKey:@"message"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"message"];

	[self didAccessValueForKey:@"message"];
	return result;
}

@dynamic thread;

- (NSMutableSet*)threadSet {
	[self willAccessValueForKey:@"thread"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"thread"];

	[self didAccessValueForKey:@"thread"];
	return result;
}

@end

