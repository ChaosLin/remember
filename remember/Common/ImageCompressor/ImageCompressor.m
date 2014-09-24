//
//  ImageCompressor.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-24.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ImageCompressor.h"

@implementation ImageCompressor

+ (void)compressImage:(UIImage*)image targetSize:(NSInteger)size finishBlock:(ImageCompressorFinishBlock)block
{
    if (!image || ![image isKindOfClass:[UIImage class]])
    {
        block(NO, [NSError new], nil);
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //    float width = image.size.width;
        float rate = 0.2;
        float rate_new = 0.2;//每次递乘的系数
        NSData* data_image = UIImageJPEGRepresentation(image, rate);
        while (size < data_image.length && rate > 0.01)
        {
            rate *= rate_new;
            data_image = UIImageJPEGRepresentation(image, rate);
        }
        //还是大
        if (data_image.length < size)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(NO, [NSError new], data_image);
            });
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                block(YES, nil, data_image);
            });
        }
    });
}
@end
