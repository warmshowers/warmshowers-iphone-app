//
//  Feedback.h
//  WS
//
//  Created by Christopher Meyer on 9/18/12.
//  Copyright (c) 2012 Red House Consulting GmbH. All rights reserved.
//

#import "FeedbackEntity.h"

@interface Feedback : FeedbackEntity

+(Feedback *)feedbackWithID:(NSNumber *)nid;

@end