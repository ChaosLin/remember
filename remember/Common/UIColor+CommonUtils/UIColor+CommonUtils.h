//
//  UIColor+CommonUtils.h
//  Holiday&Alarm
//
//  Created by Chaos Lin on 4/22/14.
//  Copyright (c) 2014 Chaos Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (CommonUtils)
+ (instancetype) colorWithHex:(unsigned int)hex;
+ (instancetype) colorWithHex:(unsigned int)hex alpha:(CGFloat)alpha;
@end
