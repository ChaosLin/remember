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
    if (!fileName || [fileName isKindOfClass:[NSString class]])
    {
        return nil;
    }
    NSArray* arr_urls = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* url_document = [arr_urls firstObject];
    NSString* str_document = [url_document absoluteString];
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
@end
