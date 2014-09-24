//
//  ImageCompressor.h
//  remember
//
//  Created by RentonTheUncoped on 14-9-24.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ImageCompressorFinishBlock)(BOOL finished, NSError* error, NSData* imageData);

@interface ImageCompressor : NSObject

+ (void)compressImage:(UIImage*)image targetSize:(NSInteger)size finishBlock:(ImageCompressorFinishBlock)block;
@end
