//
//  HomeViewController.m
//  remember
//
//  Created by Chaos Lin on 8/19/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "HomeViewController.h"
#import "MonthView.h"
#import "DayCellView.h"

@interface HomeViewController ()<MonthViewResource, MonthViewDelegate>
@property (nonatomic, strong) MonthView* monthView;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.monthView = [[MonthView alloc]initWithFrame:self.view.bounds];
    self.monthView.delegate = self;
    self.monthView.dataResource = self;
    [self.view addSubview:self.monthView];
    self.monthView.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MonthViewResource
- (DayCellView*)dayViewForDayId:(NSInteger)dayId
{
    return nil;
}
#pragma mark - MonthViewDelegate
- (void)monthView:(MonthView*)monthView didSelectDayId:(NSInteger)dayId
{
    
}
@end
