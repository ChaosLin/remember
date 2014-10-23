//
//  FilePath.h
//  remember
//
//  Created by Chaos Lin on 8/18/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilePath : NSObject
+ (NSString*)getDocumentPathWithFileName:(NSString*)fileName;
+ (NSString*)getTempPathWithFileName:(NSString*)fileName;

//用于生成对应的folderPath和fileName
//如果没有对应folder，生成一个
+ (NSString*)getDocumentPathWithFolderName:(NSString*)folderName;
+ (NSString*)getDocumentPathWithFolderName:(NSString*)folderName FileName:(NSString *)fileName;
@end
