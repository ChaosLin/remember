//
//  ReviewItemSelector.m
//  remember
//
//  Created by RentonTheUncoped on 14-8-19.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ReviewItemGenerator.h"
#import "ReviewItem.h"
#import "DateUtils.h"
#import "ReviewFacade.h"

#warning 以item直接去处理不太好，因为很可能copy、从文件生成新的实例

@interface ReviewItemGenerator()
- (BOOL)addItem:(ReviewItem*)item forDayID:(NSInteger)dayID;
- (BOOL)removeItem:(ReviewItem*)item;
- (BOOL)removeItem:(ReviewItem*)item forDayID:(NSInteger)dayID;
@property (nonatomic, strong) NSMutableDictionary* dic_dayID2ItemArr;
@end

@implementation ReviewItemGenerator

static ReviewItemGenerator* generator = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        generator = [[ReviewItemGenerator alloc]init];
    });
    return generator;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.dic_dayID2ItemArr = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)refresh//开始生成自己的数据
{
    [self.dic_dayID2ItemArr removeAllObjects];
    NSArray* arr_items = [[ReviewFacade sharedInstance] items];
    for (ReviewItem* item in arr_items)
    {
        if (!item.finished)
        {
            for (NSInteger i = item.time_reviews + 1; i <= cycle_count; i++)
            {
                NSInteger dayID = [item getReviewDateIdOnIndex:i];
                if (-1 != dayID)
                {
                    NSString* str_dayID = GetStringFromDayID(dayID);
                    NSMutableArray* arr_items = (NSMutableArray*)[self.dic_dayID2ItemArr valueForKey:str_dayID];
                    if (!arr_items)
                    {
                        arr_items = [NSMutableArray array];
                        [self.dic_dayID2ItemArr setValue:arr_items forKey:str_dayID];
                    }
                    [arr_items addObject:item];
                }
            }
        }
    }
    return;
}

- (NSArray*)getTodaysReviewItems
{
    return [self.dic_dayID2ItemArr valueForKey:GetStringFromDayID([DateUtils getTodayDateId])];
}

- (NSArray*)getReviewItemsForDayID:(NSInteger)dayID
{
    return [self.dic_dayID2ItemArr valueForKey:GetStringFromDayID(dayID)];
}

- (BOOL)refreshForItem:(ReviewItem*)item//根据item的状态刷新自己的数据
{
    [self removeItem:item];
    if (!item.finished)
    {
        for (NSInteger i = item.time_reviews + 1; i <= cycle_count; i++)
        {
            NSInteger dayID = [item getReviewDateIdOnIndex:i];
            if (-1 != dayID)
            {
                NSString* str_dayID = GetStringFromDayID(dayID);
                NSMutableArray* arr_items = (NSMutableArray*)[self.dic_dayID2ItemArr valueForKey:str_dayID];
                if (!arr_items)
                {
                    arr_items = [NSMutableArray array];
                    [self.dic_dayID2ItemArr setValue:arr_items forKey:str_dayID];
                }
                [arr_items addObject:item];
            }
        }
    }
    return YES;
}
#pragma mark - private

- (BOOL)addItem:(ReviewItem*)item forDayID:(NSInteger)dayID
{
    BOOL result = NO;
    NSMutableArray* arr_items = (NSMutableArray*)[self getReviewItemsForDayID:dayID];
    if (![arr_items containsObject:item])
    {
        result = YES;
        [arr_items addObject:item];
    }
    return result;
}

- (BOOL)removeItem:(ReviewItem*)item
{
    __block BOOL result = NO;
    NSArray* arr_items = self.dic_dayID2ItemArr.allValues;
    [arr_items enumerateObjectsUsingBlock:^(NSMutableArray* obj, NSUInteger idx, BOOL *stop) {
        [obj removeObject:item];
        result = YES;
    }];
    return result;
}

- (BOOL)removeItem:(ReviewItem*)item forDayID:(NSInteger)dayID
{
    BOOL result = NO;
    NSMutableArray* arr_items = (NSMutableArray*)[self getReviewItemsForDayID:dayID];
    if ([arr_items containsObject:item])
    {
        result = YES;
        [arr_items removeObject:item];
    }
    return result;
}

#pragma mark - output
- (NSDictionary*)generateDicDayID2Bool
{
    NSMutableDictionary* dic_result = [NSMutableDictionary dictionary];
    for (NSString* key in self.dic_dayID2ItemArr.allKeys)
    {
        if (0 != [[self.dic_dayID2ItemArr valueForKey:key] count])
        {
            [dic_result setValue:@(YES) forKeyPath:key];
        }
    }
    return dic_result;
}
@end
