// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Message.h instead.

#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

extern const struct MessageAttributes {
	__unsafe_unretained NSString *body;
	__unsafe_unretained NSString *mid;
	__unsafe_unretained NSString *timestamp;
} MessageAttributes;

extern const struct MessageRelationships {
	__unsafe_unretained NSString *author;
	__unsafe_unretained NSString *thread;
} MessageRelationships;

@class Host;
@class Thread;

@interface MessageID : NSManagedObjectID {}
@end

@interface _Message : RHManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MessageID* objectID;

@property (nonatomic, strong) NSString* body;

//- (BOOL)validateBody:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* mid;

@property (atomic) int32_t midValue;
- (int32_t)midValue;
- (void)setMidValue:(int32_t)value_;

//- (BOOL)validateMid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* timestamp;

//- (BOOL)validateTimestamp:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Host *author;

//- (BOOL)validateAuthor:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) Thread *thread;

//- (BOOL)validateThread:(id*)value_ error:(NSError**)error_;

@end

@interface _Message (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveBody;
- (void)setPrimitiveBody:(NSString*)value;

- (NSNumber*)primitiveMid;
- (void)setPrimitiveMid:(NSNumber*)value;

- (int32_t)primitiveMidValue;
- (void)setPrimitiveMidValue:(int32_t)value_;

- (NSDate*)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(NSDate*)value;

- (Host*)primitiveAuthor;
- (void)setPrimitiveAuthor:(Host*)value;

- (Thread*)primitiveThread;
- (void)setPrimitiveThread:(Thread*)value;

@end
