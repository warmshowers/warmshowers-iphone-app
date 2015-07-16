// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Host.h instead.

#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

extern const struct HostAttributes {
	__unsafe_unretained NSString *bed;
	__unsafe_unretained NSString *bikeshop;
	__unsafe_unretained NSString *campground;
	__unsafe_unretained NSString *city;
	__unsafe_unretained NSString *comments;
	__unsafe_unretained NSString *country;
	__unsafe_unretained NSString *distance;
	__unsafe_unretained NSString *favourite;
	__unsafe_unretained NSString *food;
	__unsafe_unretained NSString *fullname;
	__unsafe_unretained NSString *homephone;
	__unsafe_unretained NSString *hostid;
	__unsafe_unretained NSString *imageURL;
	__unsafe_unretained NSString *kitchenuse;
	__unsafe_unretained NSString *last_login;
	__unsafe_unretained NSString *last_updated_details;
	__unsafe_unretained NSString *last_updated_map;
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *laundry;
	__unsafe_unretained NSString *lawnspace;
	__unsafe_unretained NSString *longitude;
	__unsafe_unretained NSString *maxcyclists;
	__unsafe_unretained NSString *member_since;
	__unsafe_unretained NSString *mobilephone;
	__unsafe_unretained NSString *motel;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *notcurrentlyavailable;
	__unsafe_unretained NSString *postal_code;
	__unsafe_unretained NSString *preferred_notice;
	__unsafe_unretained NSString *province;
	__unsafe_unretained NSString *sag;
	__unsafe_unretained NSString *shower;
	__unsafe_unretained NSString *storage;
	__unsafe_unretained NSString *street;
} HostAttributes;

extern const struct HostRelationships {
	__unsafe_unretained NSString *feedback;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *thread;
} HostRelationships;

@class Feedback;
@class Message;
@class MessageThread;

@interface HostID : NSManagedObjectID {}
@end

@interface _Host : RHManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) HostID* objectID;

@property (nonatomic, strong) NSNumber* bed;

@property (atomic) BOOL bedValue;
- (BOOL)bedValue;
- (void)setBedValue:(BOOL)value_;

//- (BOOL)validateBed:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* bikeshop;

//- (BOOL)validateBikeshop:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* campground;

//- (BOOL)validateCampground:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* city;

//- (BOOL)validateCity:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* comments;

//- (BOOL)validateComments:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* country;

//- (BOOL)validateCountry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* distance;

@property (atomic) double distanceValue;
- (double)distanceValue;
- (void)setDistanceValue:(double)value_;

//- (BOOL)validateDistance:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* favourite;

@property (atomic) BOOL favouriteValue;
- (BOOL)favouriteValue;
- (void)setFavouriteValue:(BOOL)value_;

//- (BOOL)validateFavourite:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* food;

@property (atomic) BOOL foodValue;
- (BOOL)foodValue;
- (void)setFoodValue:(BOOL)value_;

//- (BOOL)validateFood:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fullname;

//- (BOOL)validateFullname:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* homephone;

//- (BOOL)validateHomephone:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* hostid;

@property (atomic) int32_t hostidValue;
- (int32_t)hostidValue;
- (void)setHostidValue:(int32_t)value_;

//- (BOOL)validateHostid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* imageURL;

//- (BOOL)validateImageURL:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* kitchenuse;

@property (atomic) BOOL kitchenuseValue;
- (BOOL)kitchenuseValue;
- (void)setKitchenuseValue:(BOOL)value_;

//- (BOOL)validateKitchenuse:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_login;

//- (BOOL)validateLast_login:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_updated_details;

//- (BOOL)validateLast_updated_details:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_updated_map;

//- (BOOL)validateLast_updated_map:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* latitude;

@property (atomic) double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* laundry;

@property (atomic) BOOL laundryValue;
- (BOOL)laundryValue;
- (void)setLaundryValue:(BOOL)value_;

//- (BOOL)validateLaundry:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* lawnspace;

@property (atomic) BOOL lawnspaceValue;
- (BOOL)lawnspaceValue;
- (void)setLawnspaceValue:(BOOL)value_;

//- (BOOL)validateLawnspace:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* longitude;

@property (atomic) double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* maxcyclists;

@property (atomic) int32_t maxcyclistsValue;
- (int32_t)maxcyclistsValue;
- (void)setMaxcyclistsValue:(int32_t)value_;

//- (BOOL)validateMaxcyclists:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* member_since;

//- (BOOL)validateMember_since:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* mobilephone;

//- (BOOL)validateMobilephone:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* motel;

//- (BOOL)validateMotel:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* notcurrentlyavailable;

@property (atomic) BOOL notcurrentlyavailableValue;
- (BOOL)notcurrentlyavailableValue;
- (void)setNotcurrentlyavailableValue:(BOOL)value_;

//- (BOOL)validateNotcurrentlyavailable:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* postal_code;

//- (BOOL)validatePostal_code:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* preferred_notice;

//- (BOOL)validatePreferred_notice:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* province;

//- (BOOL)validateProvince:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* sag;

@property (atomic) BOOL sagValue;
- (BOOL)sagValue;
- (void)setSagValue:(BOOL)value_;

//- (BOOL)validateSag:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* shower;

@property (atomic) BOOL showerValue;
- (BOOL)showerValue;
- (void)setShowerValue:(BOOL)value_;

//- (BOOL)validateShower:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* storage;

@property (atomic) BOOL storageValue;
- (BOOL)storageValue;
- (void)setStorageValue:(BOOL)value_;

//- (BOOL)validateStorage:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* street;

//- (BOOL)validateStreet:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *feedback;

- (NSMutableSet*)feedbackSet;

@property (nonatomic, strong) NSSet *message;

- (NSMutableSet*)messageSet;

@property (nonatomic, strong) NSSet *thread;

- (NSMutableSet*)threadSet;

@end

@interface _Host (FeedbackCoreDataGeneratedAccessors)
- (void)addFeedback:(NSSet*)value_;
- (void)removeFeedback:(NSSet*)value_;
- (void)addFeedbackObject:(Feedback*)value_;
- (void)removeFeedbackObject:(Feedback*)value_;

@end

@interface _Host (MessageCoreDataGeneratedAccessors)
- (void)addMessage:(NSSet*)value_;
- (void)removeMessage:(NSSet*)value_;
- (void)addMessageObject:(Message*)value_;
- (void)removeMessageObject:(Message*)value_;

@end

@interface _Host (ThreadCoreDataGeneratedAccessors)
- (void)addThread:(NSSet*)value_;
- (void)removeThread:(NSSet*)value_;
- (void)addThreadObject:(MessageThread*)value_;
- (void)removeThreadObject:(MessageThread*)value_;

@end

@interface _Host (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveBed;
- (void)setPrimitiveBed:(NSNumber*)value;

- (BOOL)primitiveBedValue;
- (void)setPrimitiveBedValue:(BOOL)value_;

- (NSString*)primitiveBikeshop;
- (void)setPrimitiveBikeshop:(NSString*)value;

- (NSString*)primitiveCampground;
- (void)setPrimitiveCampground:(NSString*)value;

- (NSString*)primitiveCity;
- (void)setPrimitiveCity:(NSString*)value;

- (NSString*)primitiveComments;
- (void)setPrimitiveComments:(NSString*)value;

- (NSString*)primitiveCountry;
- (void)setPrimitiveCountry:(NSString*)value;

- (NSNumber*)primitiveDistance;
- (void)setPrimitiveDistance:(NSNumber*)value;

- (double)primitiveDistanceValue;
- (void)setPrimitiveDistanceValue:(double)value_;

- (NSNumber*)primitiveFavourite;
- (void)setPrimitiveFavourite:(NSNumber*)value;

- (BOOL)primitiveFavouriteValue;
- (void)setPrimitiveFavouriteValue:(BOOL)value_;

- (NSNumber*)primitiveFood;
- (void)setPrimitiveFood:(NSNumber*)value;

- (BOOL)primitiveFoodValue;
- (void)setPrimitiveFoodValue:(BOOL)value_;

- (NSString*)primitiveFullname;
- (void)setPrimitiveFullname:(NSString*)value;

- (NSString*)primitiveHomephone;
- (void)setPrimitiveHomephone:(NSString*)value;

- (NSNumber*)primitiveHostid;
- (void)setPrimitiveHostid:(NSNumber*)value;

- (int32_t)primitiveHostidValue;
- (void)setPrimitiveHostidValue:(int32_t)value_;

- (NSString*)primitiveImageURL;
- (void)setPrimitiveImageURL:(NSString*)value;

- (NSNumber*)primitiveKitchenuse;
- (void)setPrimitiveKitchenuse:(NSNumber*)value;

- (BOOL)primitiveKitchenuseValue;
- (void)setPrimitiveKitchenuseValue:(BOOL)value_;

- (NSDate*)primitiveLast_login;
- (void)setPrimitiveLast_login:(NSDate*)value;

- (NSDate*)primitiveLast_updated_details;
- (void)setPrimitiveLast_updated_details:(NSDate*)value;

- (NSDate*)primitiveLast_updated_map;
- (void)setPrimitiveLast_updated_map:(NSDate*)value;

- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;

- (NSNumber*)primitiveLaundry;
- (void)setPrimitiveLaundry:(NSNumber*)value;

- (BOOL)primitiveLaundryValue;
- (void)setPrimitiveLaundryValue:(BOOL)value_;

- (NSNumber*)primitiveLawnspace;
- (void)setPrimitiveLawnspace:(NSNumber*)value;

- (BOOL)primitiveLawnspaceValue;
- (void)setPrimitiveLawnspaceValue:(BOOL)value_;

- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;

- (NSNumber*)primitiveMaxcyclists;
- (void)setPrimitiveMaxcyclists:(NSNumber*)value;

- (int32_t)primitiveMaxcyclistsValue;
- (void)setPrimitiveMaxcyclistsValue:(int32_t)value_;

- (NSDate*)primitiveMember_since;
- (void)setPrimitiveMember_since:(NSDate*)value;

- (NSString*)primitiveMobilephone;
- (void)setPrimitiveMobilephone:(NSString*)value;

- (NSString*)primitiveMotel;
- (void)setPrimitiveMotel:(NSString*)value;

- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;

- (NSNumber*)primitiveNotcurrentlyavailable;
- (void)setPrimitiveNotcurrentlyavailable:(NSNumber*)value;

- (BOOL)primitiveNotcurrentlyavailableValue;
- (void)setPrimitiveNotcurrentlyavailableValue:(BOOL)value_;

- (NSString*)primitivePostal_code;
- (void)setPrimitivePostal_code:(NSString*)value;

- (NSString*)primitivePreferred_notice;
- (void)setPrimitivePreferred_notice:(NSString*)value;

- (NSString*)primitiveProvince;
- (void)setPrimitiveProvince:(NSString*)value;

- (NSNumber*)primitiveSag;
- (void)setPrimitiveSag:(NSNumber*)value;

- (BOOL)primitiveSagValue;
- (void)setPrimitiveSagValue:(BOOL)value_;

- (NSNumber*)primitiveShower;
- (void)setPrimitiveShower:(NSNumber*)value;

- (BOOL)primitiveShowerValue;
- (void)setPrimitiveShowerValue:(BOOL)value_;

- (NSNumber*)primitiveStorage;
- (void)setPrimitiveStorage:(NSNumber*)value;

- (BOOL)primitiveStorageValue;
- (void)setPrimitiveStorageValue:(BOOL)value_;

- (NSString*)primitiveStreet;
- (void)setPrimitiveStreet:(NSString*)value;

- (NSMutableSet*)primitiveFeedback;
- (void)setPrimitiveFeedback:(NSMutableSet*)value;

- (NSMutableSet*)primitiveMessage;
- (void)setPrimitiveMessage:(NSMutableSet*)value;

- (NSMutableSet*)primitiveThread;
- (void)setPrimitiveThread:(NSMutableSet*)value;

@end
