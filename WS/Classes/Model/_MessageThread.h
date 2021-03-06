// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MessageThread.h instead.

#import <CoreData/CoreData.h>
#import "RHManagedObject.h"

extern const struct MessageThreadAttributes {
	__unsafe_unretained NSString *count;
	__unsafe_unretained NSString *is_new;
	__unsafe_unretained NSString *last_updated;
	__unsafe_unretained NSString *subject;
	__unsafe_unretained NSString *threadid;
} MessageThreadAttributes;

extern const struct MessageThreadRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *user;
} MessageThreadRelationships;

@class Message;
@class Host;

@interface MessageThreadID : NSManagedObjectID {}
@end

@interface _MessageThread : RHManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MessageThreadID* objectID;

@property (nonatomic, strong) NSNumber* count;

@property (atomic) int32_t countValue;
- (int32_t)countValue;
- (void)setCountValue:(int32_t)value_;

//- (BOOL)validateCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* is_new;

@property (atomic) int32_t is_newValue;
- (int32_t)is_newValue;
- (void)setIs_newValue:(int32_t)value_;

//- (BOOL)validateIs_new:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* last_updated;

//- (BOOL)validateLast_updated:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* subject;

//- (BOOL)validateSubject:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* threadid;

@property (atomic) int32_t threadidValue;
- (int32_t)threadidValue;
- (void)setThreadidValue:(int32_t)value_;

//- (BOOL)validateThreadid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) Host *user;

//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;

@end

@interface _MessageThread (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(Message*)value_;
- (void)removeMessagesObject:(Message*)value_;

@end

@interface _MessageThread (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveCount;
- (void)setPrimitiveCount:(NSNumber*)value;

- (int32_t)primitiveCountValue;
- (void)setPrimitiveCountValue:(int32_t)value_;

- (NSNumber*)primitiveIs_new;
- (void)setPrimitiveIs_new:(NSNumber*)value;

- (int32_t)primitiveIs_newValue;
- (void)setPrimitiveIs_newValue:(int32_t)value_;

- (NSDate*)primitiveLast_updated;
- (void)setPrimitiveLast_updated:(NSDate*)value;

- (NSString*)primitiveSubject;
- (void)setPrimitiveSubject:(NSString*)value;

- (NSNumber*)primitiveThreadid;
- (void)setPrimitiveThreadid:(NSNumber*)value;

- (int32_t)primitiveThreadidValue;
- (void)setPrimitiveThreadidValue:(int32_t)value_;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (Host*)primitiveUser;
- (void)setPrimitiveUser:(Host*)value;

@end
