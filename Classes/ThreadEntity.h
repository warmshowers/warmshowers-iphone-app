//
//  ThreadEntity.h
//  
//
//  Created by Christopher Meyer on 10/05/15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Host;

@interface ThreadEntity : RHManagedObject

@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * threadid;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSSet *participants;
@end

@interface ThreadEntity (CoreDataGeneratedAccessors)

- (void)addParticipantsObject:(Host *)value;
- (void)removeParticipantsObject:(Host *)value;
- (void)addParticipants:(NSSet *)values;
- (void)removeParticipants:(NSSet *)values;

@end
