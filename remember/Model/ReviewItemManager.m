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
        self.arr_items = [NSMutableArray array];
        [self load];
    }
    return self;
}

- (NSArray*)items
{
    return self.arr_items;
}

- (BOOL)save
{
    NSString* str_filePath = [FilePath getDocumentPathWithFileName:ItemFileName];
    return [NSKeyedArchiver archiveRootObject:self.arr_items toFile:str_filePath];
}

- (BOOL)load
{
    BOOL result = NO;
    NSString* str_filePath = [FilePath getDocumentPathWithFileName:ItemFileName];
    NSArray* arr_files = [NSKeyedUnarchiver unarchiveObjectWithFile:str_filePath];
    [self.arr_items removeAllObjects];
    if (arr_files && [arr_files isKindOfClass:[NSArray class]])
    {
        result = YES;
        [self.arr_items addObjectsFromArray:arr_files];
    }
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
        [self.arr_items removeObject:item];
        result = YES;
    }
    return result;
}

- (BOOL)deleteAllItems
{
    [self.arr_items removeAllObjects];
    return YES;
}
@end
