//
//  ReviewItemManager.h
//  remember
//
//  Created by Chaos Lin on 8/18/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReviewItem;
@interface ReviewItemManager : NSObject

+ (instancetype)sharedInstance;

#warning 这里似乎并不应该直接把数据抛出去，至少copy一份再抛出去，对当前类的数据操作必须得封装
- (NSArray*)items;

- (BOOL)saveToFile;
- (BOOL)loadFromFile;

- (ReviewItem*)getItemByID:(NSString*)uniqueID;

- (BOOL)addItem:(ReviewItem*)item;
- (BOOL)deleteItemByID:(NSString*)uniqueID;
- (BOOL)deleteAllItems;

- (BOOL)reviewItem:(ReviewItem*)item;
@end
