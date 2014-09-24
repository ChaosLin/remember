//
//  RTLoadingView.m
//  remember
//
//  Created by RentonTheUncoped on 14-9-24.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "RTLoadingView.h"

#define TAG_LOADINGVIEW 95588

@interface RTLoadingView()
//factory method
+ (instancetype)getLoadingViewWithSuperView:(UIView*)superView;
@end

@implementation RTLoadingView

static RTLoadingView* loadingView = nil;

+ (BOOL)showInView:(UIView*)view
{
    return [self showInView:view withTitle:nil];
}

+ (BOOL)showInView:(UIView *)view withTitle:(NSString*)title
{
    if (!view || ![view isKindOfClass:[UIView class]])
    {
        return NO;
    }
    
    if ([view viewWithTag:TAG_LOADINGVIEW])
    {
        return NO;
    }
    
    RTLoadingView* loadingView = [self getLoadingViewWithSuperView:view];
    [view addSubview:loadingView];
    return YES;
}

+ (BOOL)closeFromView:(UIView*)view
{
    if (!view || ![view isKindOfClass:[UIView class]])
    {
        return NO;
    }
    
    RTLoadingView* loadingView = (RTLoadingView*)[view viewWithTag:TAG_LOADINGVIEW];
    if (!loadingView)
    {
        return NO;
    }
    [loadingView removeFromSuperview];
    return YES;
}

//factory method
+ (instancetype)getLoadingViewWithSuperView:(UIView*)superView
{
    RTLoadingView* loadingView = [[RTLoadingView alloc]initWithFrame:superView.bounds];
    loadingView.tag = TAG_LOADINGVIEW;
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    //加进button，屏蔽触摸
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = loadingView.bounds;
    button.adjustsImageWhenHighlighted = NO;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.backgroundColor = [UIColor clearColor];
    
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingView addSubview:spinner];
    [spinner startAnimating];
    spinner.center = CGPointMake(loadingView.frame.size.width / 2.0, loadingView.frame.size.height / 2.0);
    return loadingView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    
}

@end
