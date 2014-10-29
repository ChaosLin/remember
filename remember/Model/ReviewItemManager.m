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
#import "RTLogger.h"

static ReviewItemManager* manager = nil;
#define ItemFileName @"ItemFileName.plist"
static NSString* STR_FOLDERNAME = @"ImagesAndConfig";

@interface ReviewItemManager()

@property (nonatomic, strong) NSMutableArray* arr_items;

//检查相同的元素并写日志
- (void)check;
- (void)checkAndDeleteSameItem;
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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveToFile) name:UIApplicationWillResignActiveNotification object:nil];
        self.arr_items = [NSMutableArray array];
        [self loadFromFile];
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

- (BOOL)saveToFile
{
    [self check];
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

- (BOOL)loadFromFile
{
    BOOL result = YES;
    NSString* str_filePath = [FilePath getDocumentPathWithFolderName:STR_FOLDERNAME FileName:ItemFileName];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        NSArray* arr_files = [NSKeyedUnarchiver unarchiveObjectWithFile:str_filePath];
        [self.arr_items removeAllObjects];
        if (arr_files && [arr_files isKindOfClass:[NSArray class]])
        {
            [self.arr_items addObjectsFromArray:arr_files];
        }
        [self checkAndDeleteSameItem];
        NSLog(@"%@ loading data finished", NSStringFromSelector(_cmd));
//    });
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
    [self saveToFile];
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
        [self saveToFile];
    }
    return result;
}

- (BOOL)deleteAllItems
{
    [self.arr_items removeAllObjects];
    [self saveToFile];
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
        [self saveToFile];
        return YES;
    }
    return NO;
}

- (void)check
{
    NSMutableString* str_log = [NSMutableString string];
    for (NSInteger i = 0; i < self.arr_items.count; i++)
    {
        ReviewItem* item_before = [self.arr_items objectAtIndex:i];
        for (NSInteger j = i+1; j <self.arr_items.count; j++)
        {
            ReviewItem* item_after = [self.arr_items objectAtIndex:j];
            if ([item_before.id_review isEqualToString:item_after.id_review])
            {
                [str_log appendFormat:@"item:%@ ", item_before];
            }
        }
    }
    //if there are items that has the same id
    if (0 < str_log.length)
    {
        //堆栈
        NSArray* arr_stacks = [NSThread callStackSymbols];
        //最多5层堆栈
        NSInteger number_stacks = 5;
        for (NSInteger i = 0; i < number_stacks && i < arr_stacks.count; i++)
        {
            id stackSymbol = [arr_stacks objectAtIndex:i];
            [str_log appendString:[stackSymbol description]];
        }
#ifdef DEBUG
        NSLog(@"%@", str_log);
#endif
        [[RTLogger sharedInstance] writeLogWithLogType:LOG_SameItem logInfo:str_log];
    }
}

- (void)checkAndDeleteSameItem
{
    NSMutableSet* set = [NSMutableSet new];
    for (NSInteger i = 0; i < self.arr_items.count; i++)
    {
        ReviewItem* item_before = [self.arr_items objectAtIndex:i];
        for (NSInteger j = i+1 ; j < self.arr_items.count; j++)
        {
            ReviewItem* item_after = [self.arr_items objectAtIndex:j];
            if ([item_before.id_review isEqualToString:item_after.id_review])
            {
                [set addObject:[NSNumber numberWithInteger:j]];
            }
        }
    }
    NSArray* arr_index = [set allObjects];
    arr_index = [arr_index sortedArrayWithOptions:NSSortConcurrent usingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue])
        {
            return NSOrderedAscending;
        }
        else if ([obj1 integerValue] < [obj2 integerValue])
        {
            return NSOrderedDescending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    for (NSInteger i = 0; i <arr_index.count; i++)
    {
        NSInteger index = [[arr_index objectAtIndex:i] integerValue];
        NSLog(@"remove index:%d item:%@", index, [self.arr_items objectAtIndex:index]);
        [self.arr_items removeObjectAtIndex:[arr_index[i] integerValue]];
    }
}
@end
