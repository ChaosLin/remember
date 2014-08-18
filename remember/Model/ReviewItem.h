//
//  ReviewItem.h
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewItem : NSObject<NSCoding>

@property (nonatomic, retain) NSString* id_review;//唯一的标识
@property (nonatomic) NSInteger dateId_created;
@property (nonatomic) NSInteger dateId_lastReviewed;
@property (nonatomic) NSInteger time_reviews;//复习过的次数
@property (nonatomic) BOOL finished;//是否复习完成
@property (nonatomic, readonly) BOOL delayed;//是否滞后
@end
