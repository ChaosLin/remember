//
//  ReviewItemSelector.h
//  remember
//
//  Created by RentonTheUncoped on 14-8-19.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReviewItem;
@interface ReviewItemGenerator : NSObject

+ (instancetype)sharedInstance;
- (void)refresh;//从0开始生成自己的数据

- (NSArray*)getTodaysReviewItems;
- (NSArray*)getReviewItemsForDayID:(NSInteger)dayID;

- (BOOL)refreshForItem:(ReviewItem*)item;//根据item的状态刷新自己的数据

- (NSDictionary*)generateDicDayID2Bool;
@end
