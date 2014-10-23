//
//  ReviewItemManager.m
//  remember
//
//  Created by Chaos Lin on 8/18/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "ReviewItemManager.h"
#import "FilePath.h"
#import "ReviewItem.h"

static ReviewItemManager* manager = nil;
#define ItemFileName @"ItemFileName.plist"
static NSString* STR_FOLDERNAME = @"ImagesAndConfig";

@interface ReviewItemManager()

@property (nonatomic, strong) NSMutableArray* arr_items;
@end

@implementation ReviewItemManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(save) name:UIApplicationWillResignActiveNotification object:nil];
        self.arr_items = [NSMutableArray array];
        [self load];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)items
{
    return self.arr_items;
}

- (BOOL)save
{
    NSString* str_filePath = [FilePath getDocumentPathWithFolderName:STR_FOLDERNAME FileName:ItemFileName];
    BOOL result = YES;
    NSArray* arr_items = [self.arr_items mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        BOOL archiveResult = [NSKeyedArchiver archiveRootObject:arr_items toFile:str_filePath];
        if (!archiveResult)
        {
#warning 记录一下事件，或者通知出去
        }
    });
    return result;
}

- (BOOL)load
{
    BOOL result = YES;
    NSString* str_filePath = [FilePath getDocumentPathWithFolderName:STR_FOLDERNAME FileName:ItemFileName];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSArray* arr_files = [NSKeyedUnarchiver unarchiveObjectWithFile:str_filePath];
        [self.arr_items removeAllObjects];
        if (arr_files && [arr_files isKindOfClass:[NSArray class]])
        {
            [self.arr_items addObjectsFromArray:arr_files];
        }
        NSLog(@"%@ loading data finished", NSStringFromSelector(_cmd));
    });
    return result;
}

- (ReviewItem*)getItemByID:(NSString*)uniqueID
{
    __block ReviewItem* item = nil;
    [self.arr_items enumerateObjectsUsingBlock:^(ReviewItem* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.id_review isEqualToString:uniqueID])
        {
            item = obj;
            *stop = YES;
        }
    }];
    return item;
}

#pragma mark - AddDelete

- (BOOL)addItem:(ReviewItem*)item
{
    BOOL result = NO;
    if (!item || ![item isKindOfClass:[ReviewItem class]])
    {
        result = NO;
    }
    //如果不存在，则加入
    if (![self getItemByID:item.id_review])
    {
        [self.arr_items addObject:item];
        result = YES;
    }
    [self save];
    return result;
}

- (BOOL)deleteItemByID:(NSString*)uniqueID
{
    BOOL result = NO;
    if (!uniqueID || ![uniqueID isKindOfClass:[NSString class]])
    {
        result = NO;
    }
    ReviewItem* item = [self getItemByID:uniqueID];
    if (item)
    {
        //delete image files
        for (NSInteger i = 0; i < item.count_images; i++)
        {
            NSString* str_filePath = [item getImagePathAtIndex:i];
            if (str_filePath)
            {
#warning error handleing and main thread issue
                [[NSFileManager defaultManager] removeItemAtPath:str_filePath error:nil];
            }
        }
        [self.arr_items removeObject:item];
        result = YES;
    }
    [self save];
    return result;
}

- (BOOL)deleteAllItems
{
    [self.arr_items removeAllObjects];
    [self save];
    return YES;
}

- (BOOL)reviewItem:(ReviewItem*)item
{
    if ([item shouldReviewToday])
    {
        [self.arr_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (item == obj)
            {
                [item review];
                *stop = YES;
            }
        }];
        [self save];
        return YES;
    }
    return NO;
}
@end
