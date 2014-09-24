//
//  TimeRecorder.m
//  ddDemo
//
//  Created by RentonTheUncoped on 14-9-19.
//  Copyright (c) 2014年 DangDang. All rights reserved.
//

#import "TimeRecorder.h"

static TimeRecorder* record = nil;

@interface TimeRecorder()
@property (nonatomic, strong) NSMutableDictionary* dic_tag2date;

+ (instancetype)shareInstance;
- (void)recordWithTag:(NSString*)tag;
- (void)recordFinishWithTag:(NSString*)tag;
@end

@implementation TimeRecorder

+ (instancetype)shareInstance;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        record = [[TimeRecorder alloc]init];
    });
    return record;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.dic_tag2date = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (void)recordWithTag:(NSString *)tag
{
    TimeRecorder* record = [TimeRecorder shareInstance];
    [record recordWithTag:tag];
}

- (void)recordWithTag:(NSString*)tag
{
    if (!tag || ![tag isKindOfClass:[NSString class]])
    {
        return;
    }
    NSMutableArray* arr_dates = [self.dic_tag2date valueForKey:tag];
    if (!arr_dates)
    {
        arr_dates = [NSMutableArray array];
        [self.dic_tag2date setValue:arr_dates forKey:tag];
    }
    NSDate* date_before = [arr_dates lastObject];
    NSDate* date_now = [NSDate date];
    [arr_dates addObject:date_now];
    if (date_before)
    {
        NSLog(@"tag:%@ take %f", tag, [date_now timeIntervalSinceDate:date_before]);
    }
    
}

+ (void)recordFinishWithTag:(NSString*)tag
{
    if (!tag || ![tag isKindOfClass:[NSString class]])
    {
        return;
    }
    TimeRecorder* record = [TimeRecorder shareInstance];
    [record recordFinishWithTag:tag];
}

- (void)recordFinishWithTag:(NSString *)tag
{
    [self recordWithTag:tag];
    NSLog(@"tag:%@ end", tag);
    [self.dic_tag2date removeObjectForKey:tag];
}
@end
