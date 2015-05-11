// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Thread.h instead.

#import <CoreData/CoreData.h>

extern const struct ThreadAttributes {
	__unsafe_unretained NSString *count;
	__unsafe_unretained NSString *subject;
	__unsafe_unretained NSString *threadid;
} ThreadAttributes;

extern const struct ThreadRelationships {
	__unsafe_unretained NSString *messages;
	__unsafe_unretained NSString *participants;
} ThreadRelationships;

@class NSManagedObject;
@class Host;

@interface ThreadID : NSManagedObjectID {}
@end

@interface _Thread : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ThreadID* objectID;

@property (nonatomic, strong) NSNumber* count;

@property (atomic) int32_t countValue;
- (int32_t)countValue;
- (void)setCountValue:(int32_t)value_;

//- (BOOL)validateCount:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* subject;

//- (BOOL)validateSubject:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* threadid;

@property (atomic) int32_t threadidValue;
- (int32_t)threadidValue;
- (void)setThreadidValue:(int32_t)value_;

//- (BOOL)validateThreadid:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *messages;

- (NSMutableSet*)messagesSet;

@property (nonatomic, strong) NSSet *participants;

- (NSMutableSet*)participantsSet;

@end

@interface _Thread (MessagesCoreDataGeneratedAccessors)
- (void)addMessages:(NSSet*)value_;
- (void)removeMessages:(NSSet*)value_;
- (void)addMessagesObject:(NSManagedObject*)value_;
- (void)removeMessagesObject:(NSManagedObject*)value_;

@end

@interface _Thread (ParticipantsCoreDataGeneratedAccessors)
- (void)addParticipants:(NSSet*)value_;
- (void)removeParticipants:(NSSet*)value_;
- (void)addParticipantsObject:(Host*)value_;
- (void)removeParticipantsObject:(Host*)value_;

@end

@interface _Thread (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveCount;
- (void)setPrimitiveCount:(NSNumber*)value;

- (int32_t)primitiveCountValue;
- (void)setPrimitiveCountValue:(int32_t)value_;

- (NSString*)primitiveSubject;
- (void)setPrimitiveSubject:(NSString*)value;

- (NSNumber*)primitiveThreadid;
- (void)setPrimitiveThreadid:(NSNumber*)value;

- (int32_t)primitiveThreadidValue;
- (void)setPrimitiveThreadidValue:(int32_t)value_;

- (NSMutableSet*)primitiveMessages;
- (void)setPrimitiveMessages:(NSMutableSet*)value;

- (NSMutableSet*)primitiveParticipants;
- (void)setPrimitiveParticipants:(NSMutableSet*)value;

@end
