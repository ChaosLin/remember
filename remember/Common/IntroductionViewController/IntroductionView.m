//
//  IntroductionView.m
//  remember
//
//  Created by RentonTheUncoped on 14/10/27.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "IntroductionView.h"
#define IntroductionImageNamePrefix @"Introduction"

@interface IntroductionView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) UIScrollView* scrollView;

- (IBAction)nextButtonClicked:(id)sender;
@end

@implementation IntroductionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)reloadData
{
    //remove old subviews
    NSArray* arr_subviews = [self.subviews copy];
    for (UIView* subView in arr_subviews)
    {
        [subView removeFromSuperview];
    }
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.scrollView];
    
    if (self.introductionDelegate)
    {
        NSInteger pages = -1;
        if ([self.introductionDelegate respondsToSelector:@selector(numberOfPagesForIntroductionview:)])
        {
            pages = [self.introductionDelegate numberOfPagesForIntroductionview:self];
        }
        
        if (0 >= pages)
        {
            return;
        }
        
        CGRect bounds_screen = [UIScreen mainScreen].bounds;
        float width_page = CGRectGetWidth(bounds_screen);
        float height_page = CGRectGetHeight(bounds_screen);
        
        self.scrollView.contentSize = CGSizeMake(width_page * pages, height_page);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        
        for (NSInteger i = 0; i < pages; i++)
        {
            UIImageView* imageView = [[UIImageView alloc]initWithFrame:CGRectMake(width_page * i, 0, width_page, height_page)];
            imageView.backgroundColor = [UIColor clearColor];
            NSString* str_fileName = [NSString stringWithFormat:@"%@%d", IntroductionImageNamePrefix, i+1];
            imageView.image = [UIImage imageNamed:str_fileName];
            imageView.backgroundColor = [UIColor redColor];
            [self.scrollView addSubview:imageView];
            
            //button
            if (i == pages - 1)
            {
                UIButton* button_next = [UIButton buttonWithType:UIButtonTypeCustom];
                [button_next setTitle:@"Next" forState:UIControlStateNormal];
                [button_next setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button_next.frame = CGRectMake(width_page * i + width_page - 50, height_page - 50, 50, 50);
                [button_next addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:button_next];
            }
        }
        
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(50, 300, 100, 40)];
        self.pageControl.numberOfPages = pages;
        self.pageControl.userInteractionEnabled = NO;
        self.pageControl.pageIndicatorTintColor = [UIColor greenColor];
        self.pageControl.currentPageIndicatorTintColor = [UIColor blueColor];
        [self addSubview:self.pageControl];
    }
}

//- (BOOL)checkIfNecessaryToShow
//{
//    BOOL result = NO;
//    if (self.introductionDelegate && [self.introductionDelegate respondsToSelector:@selector(currentIntroductionVersionForIntroductionView:)])
//    {
//        NSString* str_currentVersion = [self.introductionDelegate currentIntroductionVersionForIntroductionView:self];
//        //read local file
//        NSString* str_filePath = [FilePath getTempPathWithFileName:IntroductionVersionFileName];
//        NSString* str_localVersion = [NSString stringWithContentsOfFile:str_filePath encoding:NSUTF8StringEncoding error:nil];
//        if (!str_localVersion || ![str_localVersion isEqualToString:str_currentVersion])
//        {
//            result = YES;
//        }
//    }
//    return result;
//}

//- (void)save
//{
//    if (self.introductionDelegate && [self.introductionDelegate respondsToSelector:@selector(currentIntroductionVersionForIntroductionView:)])
//    {
//        NSString* str_currentVersion = [self.introductionDelegate currentIntroductionVersionForIntroductionView:self];
//        //read local file
//        NSString* str_filePath = [FilePath getTempPathWithFileName:IntroductionVersionFileName];
//        [str_currentVersion writeToFile:str_filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
//    }
//}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset = self.scrollView.contentOffset;
    CGRect bounds_screen = [UIScreen mainScreen].bounds;
    float width_page = CGRectGetWidth(bounds_screen);
    NSInteger page = offset.x / width_page;
    self.pageControl.currentPage = page;
}

- (IBAction)nextButtonClicked:(id)sender
{
    if (self.introductionDelegate && [self.introductionDelegate respondsToSelector:@selector(didClickNextButtonOfIntroductionView:)])
    {
        [self.introductionDelegate didClickNextButtonOfIntroductionView:self];
    }
}
@end
