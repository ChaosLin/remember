//
//  ReviewFacade.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-8.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ReviewFacade.h"
#import "ReviewItemManager.h"
#import "ReviewItemGenerator.h"

static ReviewFacade* facade = nil;

@interface ReviewFacade()
@property (nonatomic, strong) ReviewItemManager* itemManager;
@property (nonatomic, strong) ReviewItemGenerator* generator;
@end

@implementation ReviewFacade
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        facade = self.new;
    });
    return facade;
}

+ (void)destroy
{
    facade = nil;
}

- (instancetype)init
{
    if (self = [super init])
    {
        self.itemManager = [ReviewItemManager sharedInstance];
        self.generator = [ReviewItemGenerator sharedInstance];
    }
    return self;
}

#pragma mark - ReviewItemManger
- (BOOL)load
{
    return [self.itemManager load];
}

- (BOOL)save
{
    return [self.itemManager save];
}

- (NSArray*)items
{
    return self.itemManager.items;
}

- (ReviewItem*)getItemByID:(NSString*)uniqueID
{
    return [self.itemManager getItemByID:uniqueID];
}

- (BOOL)addItem:(ReviewItem*)item
{
    return [self.itemManager addItem:item];
}

- (BOOL)deleteItemByID:(NSString*)uniqueID
{
    BOOL result = [self.itemManager deleteItemByID:uniqueID];
    if (result)
    {
        [self.generator refresh];
    }
    return result;
}

- (BOOL)deleteAllItems
{
    return [self.itemManager deleteAllItems];
}

- (BOOL)reviewItem:(ReviewItem*)item
{
    BOOL result = NO;
    result = [self.itemManager reviewItem:item];
    if (result)
    {
        [self.generator refreshForItem:item];
    }
    return result;
}

#pragma mark - ReviewItemGenerator
- (void)refresh//从0开始生成自己的数据
{
    [self.generator refresh];
}

- (NSArray*)getTodaysReviewItems
{
    return [self.generator getTodaysReviewItems];
}
- (NSArray*)getReviewItemsForDayID:(NSInteger)dayID
{
    return [self.generator getReviewItemsForDayID:dayID];
}

- (BOOL)refreshForItem:(ReviewItem*)item//根据item的状态刷新自己的数据
{
    return [self.generator refreshForItem:item];
}

- (NSDictionary*)generateDicDayID2Bool
{
    NSDate* date_begin = [NSDate date];
    id result = [self.generator generateDicDayID2Bool];
    NSDate* date_end = [NSDate date];
    NSLog(@"%f", [date_end timeIntervalSinceDate:date_begin]);
    return result;
}
@end
