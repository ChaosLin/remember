//
//  ReviewItem.m
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ReviewItem.h"

@implementation ReviewItem

#pragma mark - NSCoding
//@property (nonatomic, retain) NSString* id_review;//唯一的标识
//@property (nonatomic) NSInteger dateId_created;
//@property (nonatomic) NSInteger dateId_lastReviewed;
//@property (nonatomic) NSInteger time_reviews;//复习过的次数
//@property (nonatomic) BOOL finished;//是否复习完成
//@property (nonatomic, readonly) BOOL delayed;//是否滞后
#define key_id_review @"id_review"
#define key_dateId_created @"dateId_created"
#define key_dateId_lastReviewed @"dateId_lastReviewed"
#define key_time_reviews @"time_reviews"
#define key_finished @"finished"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id_review forKey:key_id_review];
    [aCoder encodeInteger:self.dateId_created forKey:key_dateId_created];
    [aCoder encodeInteger:self.dateId_lastReviewed forKey:key_dateId_lastReviewed];
    [aCoder encodeInteger:self.time_reviews forKey:key_time_reviews];
    [aCoder encodeBool:self.finished forKey:key_finished];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        self.id_review = [aDecoder decodeObjectForKey:key_id_review];
        self.dateId_created = [aDecoder decodeIntegerForKey:key_dateId_created];
        self.dateId_lastReviewed = [aDecoder decodeIntegerForKey:key_dateId_lastReviewed];
        self.time_reviews = [aDecoder decodeIntegerForKey:key_time_reviews];
        self.finished = [aDecoder decodeBoolForKey:key_finished];
    }
    return self;
}
@end
