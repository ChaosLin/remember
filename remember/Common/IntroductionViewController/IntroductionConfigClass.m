//
//  IntroductionConfigClass.m
//  remember
//
//  Created by RentonTheUncoped on 14/10/27.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "IntroductionConfigClass.h"
#import "FilePath.h"

#define IntroductionVersionFileName @"IntroductionVersionFile"

static IntroductionConfigClass* config = nil;

@interface IntroductionConfigClass()
@end

@implementation IntroductionConfigClass

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [self new];
    });
    return config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (BOOL)shouldReview
{
    BOOL result = NO;
    if ([self currentVersion])
    {
        NSString* str_currentVersion = [self currentVersion];
        //read local file
        NSString* str_filePath = [FilePath getTempPathWithFileName:IntroductionVersionFileName];
        NSError* error = nil;
        NSString* str_localVersion = [NSString stringWithContentsOfFile:str_filePath encoding:NSUTF8StringEncoding error:&error];
        if (!str_localVersion || ![str_localVersion isEqualToString:str_currentVersion])
        {
            result = YES;
        }
    }
    return result;
}

- (void)saveCurrentVersion
{
    if ([self currentVersion])
    {
        NSString* str_currentVersion = [self currentVersion];
        //read local file
        NSString* str_filePath = [FilePath getTempPathWithFileName:IntroductionVersionFileName];
        NSError* error = nil;
        BOOL result = [str_currentVersion writeToFile:str_filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!result)
        {
            NSLog(@"Write version file failed:%@", error);
        }
    }
}

#pragma mark - Config

- (NSInteger)numberOfPages
{
    return 3;
}

- (NSString*)currentVersion
{
    return @"1.0.0";
}
@end
