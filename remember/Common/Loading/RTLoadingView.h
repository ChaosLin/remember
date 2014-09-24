//
//  RTLoadingView.h
//  remember
//
//  Created by RentonTheUncoped on 14-9-24.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RTLoadingView : UIView

+ (BOOL)showInView:(UIView*)view;
+ (BOOL)showInView:(UIView *)view withTitle:(NSString*)title;
+ (BOOL)closeFromView:(UIView*)view;
@end
