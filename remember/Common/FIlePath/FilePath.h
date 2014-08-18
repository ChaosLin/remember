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
@end
