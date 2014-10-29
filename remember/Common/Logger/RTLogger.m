//
//  DDLogger.m
//  DDEngine
//
//  Created by RentonTheUncoped on 14-10-15.
//  Copyright (c) 2014年 www.dangdang.com. All rights reserved.
//

#import "RTLogger.h"
#import "FilePath.h"

static RTLogger* logger;
//日志文件最大的长度，现在定为100k,再长了没什么意义
#define Bytes_LogFile_MaxLength 0.1 * 1000000

@interface RTLogger()
@property (nonatomic, retain) NSMutableArray* arr_services;

- (NSString*)getFilePathForLogFileWithFileName:(NSString*)fileName;
- (NSString*)getFileNameForLogType:(LOG_Type)type;


- (NSString*)readLogWithFileName:(NSString*)fileName error:(NSError**)error;
- (BOOL)writeLogWithFileName:(NSString*)fileName logInfo:(NSString*)log;
- (void)uploadLogForFile:(NSString*)fileName;
- (BOOL)removeLogForFile:(NSString*)fileName;
@end

@implementation RTLogger

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logger = RTLogger.new;
    });
    return logger;
}

+ (void)destroy
{
    logger = nil;
}

 - (instancetype)init
{
    self = [super init];
    if (self) {
        self.arr_services = [NSMutableArray arrayWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
}

- (NSString*)getFilePathForLogFileWithFileName:(NSString*)fileName
{
    NSString* str_filePath = [FilePath getTempPathWithFileName:fileName];
    return str_filePath;
}

- (NSString*)readLogWithFileName:(NSString*)fileName error:(NSError**)error
{
    if (!fileName || ![fileName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSString* str_result = nil;
    NSString* str_filePath = [self getFilePathForLogFileWithFileName:fileName];
    str_result = [NSString stringWithContentsOfFile:str_filePath encoding:NSUTF8StringEncoding error:error];
    
    return str_result;
}

- (BOOL)writeLogWithFileName:(NSString*)fileName logInfo:(NSString *)log
{
    BOOL result = NO;
    if (!fileName || ![fileName isKindOfClass:[NSString class]] || 0 >= fileName.length ||
        !log || ![log isKindOfClass:[NSString class]] || 0 >= log.length)
    {
        return result;
    }
    
    NSError* error = nil;
    NSString* str_log_origin = [self readLogWithFileName:fileName error:&error];
    NSMutableString* str_log_new;
    if (!str_log_origin || error)
    {
        str_log_new = [NSMutableString string];
    }
    else
    {
        str_log_new = [NSMutableString stringWithString:str_log_origin];
    }
    
    [str_log_new appendString:log];
    [str_log_new appendString:@"\n"];
    
    NSError* error_write = nil;
    NSString* str_filePath = [self getFilePathForLogFileWithFileName:fileName];
    //如果日志文件太长，不再继续往里面写东西
    if (Bytes_LogFile_MaxLength >= str_filePath.length)
    {
        result = [str_log_new writeToFile:str_filePath atomically:YES encoding:NSUTF8StringEncoding error:&error_write];
        
        if (error_write)
        {
            NSLog(@"write log file error fileName:%@ error:%@", fileName, error_write.description);
        }
    }
    else
    {
        NSLog(@"write log file error, file is too huge");
    }
    
    return result;
}

- (void)uploadLogForFile:(NSString*)fileName
{
    NSError* error = nil;
    NSString* str_log = [self readLogWithFileName:fileName error:&error];
    if (str_log)
    {
        //加上文件名是
        NSMutableString* str_log_final = [NSMutableString string];
        [str_log_final appendString:fileName];
        [str_log_final appendString:@" "];
        [str_log_final appendString:str_log];
    }
    else
    {
        if (error)
        {
            NSLog(@"upload log error fileName:%@ error:%@", fileName, error.description);
        }
    }
}

- (BOOL)removeLogForFile:(NSString*)fileName
{
    NSString* str_path = [self getFilePathForLogFileWithFileName:fileName];
    BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:str_path isDirectory:nil];
    if (fileExist)
    {
        [[NSFileManager defaultManager] removeItemAtPath:str_path error:nil];
    }
    return YES;
}

#pragma mark - Request

#pragma mark - Interface
- (NSString*)getFileNameForLogType:(LOG_Type)type
{
    NSString* str_result = @"";
    NSArray* arr_fileNames = LOG_logFileNames;
    if (type < arr_fileNames.count)
    {
        str_result = [arr_fileNames objectAtIndex:type];
    }
    return str_result;
}

- (NSString*)readLogWithLogType:(LOG_Type)type error:(NSError**)error
{
    NSString* str_fileName = [self getFileNameForLogType:type];
    return [self readLogWithFileName:str_fileName error:error];
}

- (BOOL)writeLogWithLogType:(LOG_Type)type logInfo:(NSString*)log
{
    NSString* str_fileName = [self getFileNameForLogType:type];
    return [self writeLogWithFileName:str_fileName logInfo:log];
}

- (void)uploadLogForLogType:(LOG_Type)type
{
    NSString* str_fileName = [self getFileNameForLogType:type];
    return [self uploadLogForFile:str_fileName];
}

- (BOOL)removeLogForLogType:(LOG_Type)type
{
    NSString* str_fileName = [self getFileNameForLogType:type];
    return [self removeLogForFile:str_fileName];
}
@end
