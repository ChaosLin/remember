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

- (NSArray*)items;

- (BOOL)save;
- (BOOL)load;

- (ReviewItem*)getItemByID:(NSString*)uniqueID;

- (BOOL)addItem:(ReviewItem*)item;
- (BOOL)deleteItemByID:(NSString*)uniqueID;
- (BOOL)deleteAllItems;

- (BOOL)reviewItem:(ReviewItem*)item;
@end
