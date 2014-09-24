//
//  TimeRecorder.h
//  ddDemo
//
//  Created by RentonTheUncoped on 14-9-19.
//  Copyright (c) 2014年 DangDang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeRecorder : NSObject

+ (void)recordWithTag:(NSString*)tag;

+ (void)recordFinishWithTag:(NSString*)tag;
@end
