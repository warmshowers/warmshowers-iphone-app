//
//  Feedback.m
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "Feedback.h"

@implementation Feedback

+(NSString *)modelName {
	return @"WS";
}

+(Feedback *)feedbackWithID:(NSNumber *)nid {
	
	Feedback *feedback = [Feedback getWithPredicate:[NSPredicate predicateWithFormat:@"nid=%i", [nid intValue]]];
	
	if (feedback) {
		return feedback;
	}
	
	feedback = [Feedback newEntity];
	feedback.nid = nid;
	
	return feedback;
	
}

@end
