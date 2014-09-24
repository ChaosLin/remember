//
//  UIImageView+setPath.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-23.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface UIImageView (setPath)
//
//@end

@implementation UIImageView (setPath)

- (void)setImageWithPath:(NSString*)path
{
    if (!path || ![path isKindOfClass:[NSString class]])
    {
        return;
    }
    __weak UIImageView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        if (image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.image = image;
            });
        }
    });
}

- (void)setThumbnailImageWithPath:(NSString*)path size:(CGSize)size
{
    if (!path || ![path isKindOfClass:[NSString class]] || CGSizeEqualToSize(size, CGSizeZero))
    {
        return;
    }
    __weak UIImageView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        if (image)
        {
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            UIImage* image_thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.image = image_thumbnail;
            });
        }
    });
}
@end