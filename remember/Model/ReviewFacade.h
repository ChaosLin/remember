//
//  ReviewFacade.h
//  remember
//
//  Created by RentonTheUncoped on 14-9-8.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReviewItem, ReviewItemManager, ReviewItemGenerator;

@interface ReviewFacade : NSObject

+ (instancetype)sharedInstance;
+ (void)destroy;

#pragma mark - ReviewItemManger
- (BOOL)loadFromFile;
- (BOOL)save;

- (NSArray*)items;
- (ReviewItem*)getItemByID:(NSString*)uniqueID;

- (BOOL)addItem:(ReviewItem*)item;
- (BOOL)deleteItemByID:(NSString*)uniqueID;
- (BOOL)deleteAllItems;

- (BOOL)reviewItem:(ReviewItem*)item;

#pragma mark - ReviewItemGenerator
- (void)refresh;//从0开始生成自己的数据

- (NSArray*)getTodaysReviewItems;
- (NSArray*)getReviewItemsForDayID:(NSInteger)dayID;

- (BOOL)refreshForItem:(ReviewItem*)item;//根据item的状态刷新自己的数据

- (NSDictionary*)generateDicDayID2Bool;
@end
