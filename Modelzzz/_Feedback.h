// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Feedback.h instead.

#import <CoreData/CoreData.h>

extern const struct FeedbackAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *fullname;
	__unsafe_unretained NSString *hostOrGuest;
	__unsafe_unretained NSString *nid;
} FeedbackAttributes;

extern const struct FeedbackRelationships {
	__unsafe_unretained NSString *host;
} FeedbackRelationships;

@class Host;

@interface FeedbackID : NSManagedObjectID {}
@end

@interface _Feedback : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) FeedbackID* objectID;

@property (nonatomic, strong) NSString* body;

//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* date;

//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* fullname;

//- (BOOL)validateFullname:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* hostOrGuest;

//- (BOOL)validateHostOrGuest:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* nid;

@property (atomic) int32_t nidValue;
- (int32_t)nidValue;
- (void)setNidValue:(int32_t)value_;

//- (BOOL)validateNid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Host *host;

//- (BOOL)validateHost:(id*)value_ error:(NSError**)error_;

@end

@interface _Feedback (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;

- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;

- (NSString*)primitiveFullname;
- (void)setPrimitiveFullname:(NSString*)value;

- (NSString*)primitiveHostOrGuest;
- (void)setPrimitiveHostOrGuest:(NSString*)value;

- (NSNumber*)primitiveNid;
- (void)setPrimitiveNid:(NSNumber*)value;

- (int32_t)primitiveNidValue;
- (void)setPrimitiveNidValue:(int32_t)value_;

- (Host*)primitiveHost;
- (void)setPrimitiveHost:(Host*)value;

@end
