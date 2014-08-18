//
//  UniqueID.m
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "UniqueID.h"

@implementation UniqueID

+ (NSString*)getUniqueID
{
    return [[NSProcessInfo processInfo] globallyUniqueString];
}
@end
