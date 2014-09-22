//
//  ReviewItem.m
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "ReviewItem.h"
#import "DateUtils.h"
#import "UniqueID.h"
#import "FilePath.h"

@implementation ReviewItem

- (id)init
{
    if (self = [super init])
    {
        self.id_review = [UniqueID getUniqueID];
        self.dateId_created = [DateUtils getTodayDateId];
        self.dateId_lastReviewed = [DateUtils getTodayDateId];
    }
    return self;
}

- (BOOL)shouldReviewToday
{
    BOOL result = NO;
    BOOL isDelayed = self.delayed;
    if (isDelayed || (!isDelayed && [self getNextReviewDateId] == [DateUtils getTodayDateId]))
    {
        result = YES;
    }
    return result;
}

- (BOOL)review
{
    self.dateId_lastReviewed = [DateUtils getTodayDateId];
    self.time_reviews += 1;
    if (self.time_reviews >= cycle_count){
        self.finished = YES;
    }
    //通知另外一个类去更新，并更新数据源
    return YES;
}

- (NSInteger)getNextReviewDateId
{
    //如果没有delay，就取下一个日子,否则返回今天
    NSInteger dayId_next = self.dateId_lastReviewed;
    if (0 == self.time_reviews){
        dayId_next = self.dateId_created;
    }
    else {
        NSInteger times = self.time_reviews;
        dayId_next = [DateUtils getDayIdWithDays:cycle_date[times] - cycle_date[times - 1] afterDayId:self.dateId_lastReviewed];
    }
    
    NSInteger today = [DateUtils getTodayDateId];
    if (today > dayId_next){
        return [DateUtils getTodayDateId];
    }
    else{
        return dayId_next;
    }
}

- (NSInteger)getReviewDateIdOnIndex:(NSInteger)index//得到第index的周期的复习时间
{
    if (self.time_reviews >= index || index > cycle_count){
        return -1;
    }
    else{
        if (!self.delayed){
            if (0 == self.time_reviews){
                return [DateUtils getDayIdWithDays:cycle_date[index - 1] afterDayId:self.dateId_lastReviewed];
            }
            return [DateUtils getDayIdWithDays:cycle_date[index - 1] - cycle_date[self.time_reviews - 1] afterDayId:self.dateId_lastReviewed];
        }
        else{
            if (index == self.time_reviews + 1)
            {
                return [DateUtils getTodayDateId];
            }
            return [DateUtils getDayIdWithDays:cycle_date[index - 1] - cycle_date[self.time_reviews] afterDayId:[DateUtils getTodayDateId]];
        }
    }
    return 0;
}

#pragma mark - 工厂方法
+ (instancetype)createReviewItem
{
    ReviewItem* item = [[ReviewItem alloc]init];
    return item;
}

#pragma mark - NSCoding
//@property (nonatomic, strong) NSString* id_review;//唯一的标识
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
#define key_imageCount @"imageCount"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.id_review forKey:key_id_review];
    [aCoder encodeInteger:self.dateId_created forKey:key_dateId_created];
    [aCoder encodeInteger:self.dateId_lastReviewed forKey:key_dateId_lastReviewed];
    [aCoder encodeInteger:self.time_reviews forKey:key_time_reviews];
    [aCoder encodeBool:self.finished forKey:key_finished];
    [aCoder encodeInteger:self.count_images forKey:key_imageCount];
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
        self.count_images = [aDecoder decodeIntegerForKey:key_imageCount];
    }
    return self;
}

#pragma mark - getter,setter
- (BOOL)delayed
{
    //如果已经复习完，为NO
    if (self.time_reviews >= cycle_count)
    {
        return NO;
    }
    
    NSInteger dayId_next = self.dateId_lastReviewed;
    if (0 == self.time_reviews){
        dayId_next = self.dateId_created;
    }
    else {
        NSInteger times = self.time_reviews;
        dayId_next = [DateUtils getDayIdWithDays:cycle_date[times] - cycle_date[times - 1] afterDayId:self.dateId_lastReviewed];
    }
    
    NSInteger today = [DateUtils getTodayDateId];
    if (today > dayId_next){
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)setDateId_lastReviewed:(NSInteger)dateId_lastReviewed
{
    _dateId_lastReviewed = dateId_lastReviewed;
}

#pragma mark - Image
- (BOOL)addImage:(UIImage *)image
{
    self.count_images += 1;
    NSString* str_fileName = [NSString stringWithFormat:@"%@_%d.jpeg", self.id_review, self.count_images];
    NSString* str_filePath = [FilePath getDocumentPathWithFileName:str_fileName];
    NSData* data_image = UIImageJPEGRepresentation(image, 1);
    return [data_image writeToFile:str_filePath atomically:YES];
}

- (BOOL)addImages:(NSArray*)images
{
    self.count_images += images.count;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[UIImage class]])
            {
                NSString* str_fileName = [NSString stringWithFormat:@"%@_%d.jpeg", self.id_review, idx + 1];
                NSString* str_filePath = [FilePath getDocumentPathWithFileName:str_fileName];
                NSData* data_image = UIImageJPEGRepresentation(obj, 1);
                BOOL result_save = [data_image writeToFile:str_filePath atomically:YES];
                NSLog(@"%@ save file:%d", NSStringFromSelector(_cmd), result_save);
            }
        }];
    });
    return YES;
}

- (UIImage*)getImageAtIndex:(NSInteger)index
{
    NSString* str_fileName = [NSString stringWithFormat:@"%@_%d.jpeg", self.id_review, index];
    NSString* str_filePath = [FilePath getDocumentPathWithFileName:str_fileName];
    return [[UIImage alloc]initWithContentsOfFile:str_filePath];
}
@end
