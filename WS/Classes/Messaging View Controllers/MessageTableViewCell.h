//
//  MessageTableViewCell.h
//  WS
//
//  Created by Christopher Meyer on 17/05/15.
//  Copyright (c) 2015 Red House Consulting GmbH. All rights reserved.
//

@interface MessageTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *fromLabel;
@property (strong, nonatomic) IBOutlet UILabel *bodyLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
