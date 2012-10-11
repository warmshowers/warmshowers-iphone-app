//
//  Feedback.m
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "Feedback.h"

@implementation Feedback

+(NSString *)entityName {
	return @"FeedbackEntity";
}

+(NSString *)modelName {
	return @"WS";
}

+(Feedback *)feedbackWithID:(NSNumber *)nid {
	
	NSArray *results = [Feedback fetchWithPredicate:[NSPredicate predicateWithFormat:@"nid=%i", [nid intValue]]];
	if ([results count] > 0) {
		return (Feedback *)[results objectAtIndex:0];
	}
	
	Feedback *newFeedback = (Feedback *)[Feedback newEntity];
	newFeedback.nid = nid;
	
	return newFeedback;
	
}

@end
