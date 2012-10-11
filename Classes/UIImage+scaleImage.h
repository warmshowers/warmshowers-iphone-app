//
//  UIImage+scaleImage.h
//  TrackMyTour
//
//  Created by Christopher Meyer on 5/9/09.
//  Copyright 2012 Red House Consulting GmbH. All rights reserved.
//

@interface UIImage (UIImage_scaleImage)

-(UIImage *)scaleImageWithmaxWidth:(float) maxWidth maxHeight:(float) maxHeight;
-(UIImage *)fillImageInBoxWithmaxWidth:(float)maxWidth maxHeight:(float)maxHeight;
-(UIImage *)roundCornersOfRadius:(int)radius;
-(UIImage *)imageByScalingAndCroppingWithmaxWidth:(float)maxWidth maxHeight:(float)maxHeight;

@end