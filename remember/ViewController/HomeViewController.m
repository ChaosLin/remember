//
//  HomeViewController.m
//  remember
//
//  Created by Chaos Lin on 8/19/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "HomeViewController.h"
#import "MonthView.h"
#import "EventDayCellView.h"
#import "ReviewItem.h"
#import "ReviewItemManager.h"
#import "ReviewItemGenerator.h"
#import "DateUtils.h"

@interface HomeViewController ()<MonthViewResource, MonthViewDelegate>
@property (nonatomic, strong) MonthView* monthView;

@property (nonatomic, strong) NSDictionary* dic_dayId2flatEvent;//dayID:YES/NO

- (void)test;//填充一些数据
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dic_dayId2flatEvent = [NSMutableDictionary dictionary];
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
    self.monthView = [[MonthView alloc]initWithFrame:self.view.bounds];
    self.monthView.delegate = self;
    self.monthView.dataResource = self;
    [self.view addSubview:self.monthView];
    [self.monthView showToday];
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
    EventDayCellView* cellView = [[EventDayCellView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    cellView.hasEvent = ([self.dic_dayId2flatEvent valueForKey:GetStringFromDayID(dayId)])? YES:NO;
    return cellView;
}
#pragma mark - MonthViewDelegate
- (void)monthView:(MonthView*)monthView didSelectDayId:(NSInteger)dayId
{
    
}

#pragma mark - test
- (void)test
{
    ReviewItem* item = [ReviewItem createReviewItem];
//    item.dateId_created = 20150818;
//    item.dateId_lastReviewed = 20150818;
    
    [[ReviewItemManager sharedInstance] addItem:item];
    [item review];
    [item review];
    
    [[ReviewItemGenerator sharedInstance] refresh];
    
    self.dic_dayId2flatEvent = [[ReviewItemGenerator sharedInstance] generateDicDayID2Bool];
    [self.monthView reloadView];
}
@end
