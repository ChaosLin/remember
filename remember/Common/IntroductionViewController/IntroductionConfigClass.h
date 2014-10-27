//
//  IntroductionConfigClass.h
//  remember
//
//  Created by RentonTheUncoped on 14/10/27.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATIONNAME_INTRODUCTIONNEXTBUTTONCLICKED @"NOTIFICATIONNAME_INTRODUCTIONNEXTBUTTONCLICKED"

@interface IntroductionConfigClass : NSObject

+ (instancetype)sharedInstance;

- (BOOL)shouldReview;
- (void)saveCurrentVersion;

- (NSInteger)numberOfPages;
- (NSString*)currentVersion;
@end
