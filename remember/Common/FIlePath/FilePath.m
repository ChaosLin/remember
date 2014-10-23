//
//  FilePath.m
//  remember
//
//  Created by Chaos Lin on 8/18/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "FilePath.h"

@implementation FilePath

+ (NSString*)getDocumentPathWithFileName:(NSString*)fileName
{
    if (!fileName || ![fileName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSArray* arr_urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* url_document = [arr_urls firstObject];
    NSString* str_document = [url_document path];
    return [str_document stringByAppendingPathComponent:fileName];
}

+ (NSString*)getTempPathWithFileName:(NSString*)fileName
{
    if (!fileName || ![fileName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
}

+ (NSString*)getDocumentFolderPathWithFolderName:(NSString*)folderName
{
    if (!folderName || ![folderName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSArray* arr_urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* url_document = [arr_urls firstObject];
    NSString* str_document = [url_document path];
    NSString* str_path = [str_document stringByAppendingPathComponent:folderName];
    NSError* error = nil;
    BOOL result_createFolder = [[NSFileManager defaultManager]createDirectoryAtPath:str_path withIntermediateDirectories:YES attributes:nil error:&error];
    if (result_createFolder)
    {
        return str_path;
    }
    else
    {
        return nil;
    }
}

+ (NSString*)getDocumentPathWithFolderName:(NSString*)folderName FileName:(NSString *)fileName
{
    if (!fileName || ![fileName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSString* path = [self getDocumentFolderPathWithFolderName:folderName];
    return [path stringByAppendingPathComponent:fileName];
}
@end
