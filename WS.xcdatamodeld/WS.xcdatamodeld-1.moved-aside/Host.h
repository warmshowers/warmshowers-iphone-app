//
//  Host.h
//  WS
//
//  Created by Christopher Meyer on 10/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Host :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * hostid;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * city;
@property (nonatomic, retain) UNKNOWN_TYPE title;
@property (nonatomic, retain) NSString * zipcode;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * province;

@end



