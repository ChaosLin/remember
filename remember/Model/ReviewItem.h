//
//  ReviewItem.h
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReviewItem : NSObject<NSCoding>

@property (nonatomic, strong) NSString* id_review;//唯一的标识
@property (nonatomic) NSInteger dateId_created;
@property (nonatomic) NSInteger dateId_lastReviewed;
@property (nonatomic) NSInteger time_reviews;//复习过的次数
@property (nonatomic) BOOL finished;//是否复习完成
@property (nonatomic, readonly) BOOL delayed;//是否滞后
@property (nonatomic) NSInteger count_images;//图片的数量,图片用id_review_1、id_review_2、id_review_3来命名

//类方法,工厂方法，生成一个随机ID标识，并用今天的ID填上～
+ (instancetype)createReviewItem;

- (BOOL)shouldReviewToday;
- (BOOL)review;
- (NSInteger)getNextReviewDateId;
//如果出现错误，比如index<当前已经复习的次数，返回-1
//index:1～7
- (NSInteger)getReviewDateIdOnIndex:(NSInteger)index;//得到第index的周期的复习时间

//addImageAndSave
- (BOOL)addImage:(UIImage*)image;
- (void)addImages:(NSArray*)images finished:(void (^)(BOOL success, NSError* error))completion;
- (NSString*)getImagePathAtIndex:(NSInteger)index;

- (UIImage*)getImageAtIndex:(NSInteger)index;
@end
