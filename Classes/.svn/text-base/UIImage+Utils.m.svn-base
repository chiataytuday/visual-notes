//
//  UIImage+Utils.m
//  VisualNotes
//
//  Created by Richard Lucas on 3/13/10.
//  Copyright 2010 lucasweb. All rights reserved.
//

#import "UIImage+Utils.h"

@interface UIImage ()
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;
- (UIImage *)cropImage:(CGRect)cropRect;
@end

@implementation UIImage (Utils)

- (UIImage *) scaleAndCropImageToScreenSize {
    CGFloat currentHeight = self.size.height;
    CGFloat currentWidth = self.size.width;
    
    if (currentHeight == currentWidth) {
        // Square
        if (currentWidth > 640) {
            return [self scaleAndCropImage:CGSizeMake(640, 640)];
        }
    } else if (currentHeight > currentWidth) {
        // Portrait
        if (self.size.height > 960) {
            return [self scaleAndCropImage:CGSizeMake(640, 960)];
        }        
    } else {
        // Landscape
        if (self.size.width > 960) {
            return [self scaleAndCropImage:CGSizeMake(960, 640)];
        }
    }
    return self;
}

- (UIImage *) scaleAndCropImage:(CGSize)newSize {
    
    // Calculate the new image size while maintaining it's scale
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint imagePoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, newSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            imagePoint.y = (targetHeight - scaledHeight) * 0.5; 
        } else {
            if (widthFactor < heightFactor) {
                imagePoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
    }  
    
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, scaledWidth, scaledHeight));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGSize scaledSize = CGSizeMake(scaledWidth, scaledHeight);
    CGAffineTransform transform = [self transformForOrientation:scaledSize];
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    BOOL transpose;
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transpose = YES;
            break;
            
        default:
            transpose = NO;
    }
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    CGRect cropRect = CGRectMake(0.0f, 0.0f, newSize.width, newSize.height);        
    newImage = [newImage cropImage:cropRect];
    
    return newImage;
}

#pragma mark -
#pragma mark Thumbnail Image

- (UIImage *)thumbnailImage:(CGFloat)thumbnailSize {  
    CGSize newSize = CGSizeMake(100.0F, 100.0F);
    UIImage *thumbnailImage = [self scaleAndCropImage:newSize];
    return thumbnailImage;
}

#pragma mark -
#pragma mark Internal Image Manipulation Methods

- (CGAffineTransform)transformForOrientation:(CGSize)newSize {
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    return transform;
}

- (UIImage *)cropImage:(CGRect)cropRect {
    UIGraphicsBeginImageContext(cropRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, cropRect.size.width, cropRect.size.height));
    CGContextTranslateCTM(context, -((self.size.width*0.5)-(cropRect.size.width*0.5)),
                          (self.size.height*0.5)-(cropRect.size.height*0.5));
    
    CGContextTranslateCTM(context, 0.0, cropRect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
    self = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return self;
}

@end
