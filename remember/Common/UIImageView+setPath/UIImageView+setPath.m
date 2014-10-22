//
//  UIImageView+setPath.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-23.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//@interface UIImageView (setPath)
//
//@end

static const void *PATHKEY = &PATHKEY;

@interface UIImageView(Path)
- (NSString*)getPath;
- (void)setPath:(NSString*)path;
@end

@implementation UIImageView (setPath)

- (NSString*)getPath
{
    return objc_getAssociatedObject(self, PATHKEY);
}

- (void)setPath:(NSString*)path
{
    objc_setAssociatedObject(self, PATHKEY, path, OBJC_ASSOCIATION_RETAIN);
}

- (void)setImageWithPath:(NSString*)path
{
    if (nil == path || [path isKindOfClass:[NSString class]])
    {
        [self setPath:path];
        if (!path)
        {
            self.image = nil;
            return;
        }
    }
    if (![path isKindOfClass:[NSString class]])
    {
        return;
    }
    
    __weak UIImageView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        if (image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[weakSelf getPath] isEqualToString:path])
                {
                    weakSelf.image = image;
                }
            });
        }
    });
}

- (void)setThumbnailImageWithPath:(NSString*)path size:(CGSize)size
{
    if (nil == path || [path isKindOfClass:[NSString class]])
    {
        [self setPath:path];
        if (!path)
        {
            self.image = nil;
            return;
        }
    }
    if (![path isKindOfClass:[NSString class]] || CGSizeEqualToSize(size, CGSizeZero) || 0 >= size.width || 0 >= size.height)
    {
        return;
    }
    __weak UIImageView* weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [UIImage imageWithContentsOfFile:path];
        if (image)
        {
            CGSize sizeNew = size;
            float width_image = image.size.width;
            float height_image = image.size.height;
            if (0 < height_image)
            {
                if (width_image / height_image > size.width / size.height)
                {
                    sizeNew.height = size.width * height_image / width_image;
                }
                else
                {
                    sizeNew.width = size.height * width_image / height_image;
                }
            }
            //注意比例
            UIGraphicsBeginImageContext(sizeNew);
            [image drawInRect:CGRectMake(0, 0, sizeNew.width, sizeNew.height)];
            UIImage* image_thumbnail = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[self getPath] isEqualToString:path])
                {
                    weakSelf.image = image_thumbnail;
                }
            });
        }
    });
}
@end