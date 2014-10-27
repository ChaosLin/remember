//
//  IntroductionViewController.m
//  remember
//
//  Created by RentonTheUncoped on 14/10/27.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "IntroductionViewController.h"
#import "IntroductionView.h"
#import "IntroductionConfigClass.h"

@interface IntroductionViewController ()<IntroductionViewDelegate>
@property (nonatomic, strong) IntroductionView* introductionView;
@end

@implementation IntroductionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.introductionView = [[IntroductionView alloc]initWithFrame:self.view.bounds];
    self.introductionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.introductionView.introductionDelegate = self;
    [self.view addSubview:self.introductionView];
    [self.introductionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IntroductionViewDelegate
- (NSInteger)numberOfPagesForIntroductionview:(IntroductionView*)indtroductionView
{
    return [[IntroductionConfigClass sharedInstance] numberOfPages];
}

- (void)didClickNextButtonOfIntroductionView:(IntroductionView*)indtroductionView
{
    [[IntroductionConfigClass sharedInstance] saveCurrentVersion];
    //post notification
    //show mainVC
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATIONNAME_INTRODUCTIONNEXTBUTTONCLICKED object:nil];
}
@end
