//
//  ReviewItemManager.m
//  remember
//
//  Created by Chaos Lin on 8/18/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "ReviewItemManager.h"
#import "FilePath.h"

static ReviewItemManager* manager = nil;
#define ItemFileName @"ItemFileName"

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
    return YES;
}

- (BOOL)load
{
    NSString* str_filePath = [FilePath getDocumentPathWithFileName:ItemFileName];
    NSArray* arr_files = [NSArray arrayWithContentsOfFile:str_filePath];
    [self.arr_items addObjectsFromArray:arr_files];
    return YES;
}

- (ReviewItem*)getItemByID:(NSString*)uniqueID
{
    return nil;
}

#pragma mark - AddDelete

- (BOOL)addItem:(ReviewItem*)item
{
    return YES;
}

- (BOOL)deleteItem:(ReviewItem*)item
{
    return YES;
}
@end
