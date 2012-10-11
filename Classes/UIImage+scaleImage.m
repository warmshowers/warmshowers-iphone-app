//
//  UIImage+scaleImage.m
//  TrackMyTour
//
//  Created by Christopher Meyer on 5/9/09.
//  Copyright 2012 Red House Consulting GmbH. All rights reserved.
//

#import "UIImage+scaleImage.h"

@implementation UIImage (UIImage_scaleImage)

-(UIImage *)scaleImageWithmaxWidth:(float)maxWidth maxHeight:(float)maxHeight {
	
	float actualHeight = self.size.height;
	float actualWidth = self.size.width;

	float imgRatio = actualWidth / actualHeight;
	float maxRatio = maxWidth / maxHeight;

	if(imgRatio < maxRatio) {
		imgRatio = maxHeight / actualHeight;
		actualWidth = imgRatio * actualWidth;
		actualHeight = maxHeight;		
	} else {
		imgRatio = maxWidth / actualWidth;
		actualHeight = imgRatio * actualHeight;     
		actualWidth = maxWidth;
	}

	return [self fillImageInBoxWithmaxWidth:actualWidth maxHeight:actualHeight];
}

-(UIImage *)fillImageInBoxWithmaxWidth:(float)maxWidth maxHeight:(float)maxHeight {	
	CGRect rect = CGRectMake(0.0, 0.0, maxWidth, maxHeight);
	UIGraphicsBeginImageContext(rect.size);
	// UIGraphicsBeginImageContextWithOptions(rect.size, YES, 1.0);
	[self drawInRect:rect];  // scales image to rect
	UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return theImage;	
}


-(UIImage *)imageByScalingAndCroppingWithmaxWidth:(float)maxWidth maxHeight:(float)maxHeight {
	CGSize targetSize = CGSizeMake(maxWidth, maxHeight);
	
	UIImage *sourceImage = self;
	UIImage *newImage = nil;        
	CGSize imageSize = sourceImage.size;
	CGFloat width = imageSize.width;
	CGFloat height = imageSize.height;
	CGFloat targetWidth = targetSize.width;
	CGFloat targetHeight = targetSize.height;
	CGFloat scaleFactor = 0.0;
	CGFloat scaledWidth = targetWidth;
	CGFloat scaledHeight = targetHeight;
	CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
	
	if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
		
        if (widthFactor > heightFactor) {
			scaleFactor = widthFactor; // scale to fit height
        } else {
			scaleFactor = heightFactor; // scale to fit width
        }
		
		scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
		
        // center the image
        if (widthFactor > heightFactor) {
			thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
		} else if (widthFactor < heightFactor) {
			thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
		}
	}       
	
	UIGraphicsBeginImageContext(targetSize); // this will crop
	
	CGRect thumbnailRect = CGRectZero;
	thumbnailRect.origin = thumbnailPoint;
	thumbnailRect.size.width  = scaledWidth;
	thumbnailRect.size.height = scaledHeight;
	
	[sourceImage drawInRect:thumbnailRect];
	
	newImage = UIGraphicsGetImageFromCurrentImageContext();
	
	if(newImage == nil) {
        NSLog(@"could not scale image");
	}
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	return newImage;
}




void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0) {
		CGContextAddRect(context, rect);
		return;
	}
	CGContextSaveGState(context);
	CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM (context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth (rect) / ovalWidth;
	fh = CGRectGetHeight (rect) / ovalHeight;
	CGContextMoveToPoint(context, fw, fh/2);
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

-(UIImage *)roundCornersOfRadius:(int)radius {
	int w = self.size.width;
	int h = self.size.height;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
	
	CGContextBeginPath(context);
	CGRect rect = CGRectMake(0, 0, w, h);
	addRoundedRectToPath(context, rect, radius, radius);
	CGContextClosePath(context);
	CGContextClip(context);
	
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), self.CGImage);
	
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	return [UIImage imageWithCGImage:imageMasked];    
}

@end