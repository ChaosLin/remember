//
//  ItemListTableViewController.m
//  remember
//
//  Created by Chaos Lin on 8/29/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "ItemListTableViewController.h"
#import "ReviewFacade.h"
#import "ReviewItem.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "ItemListCell.h"
#import "DateUtils.h"
#import "RTReviewAddItemDirector.h"
#import "MobClick.h"
#import "ConfigTableViewController.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ItemListTableViewController ()<MJPhotoBrowserDelegate>
@property (nonatomic, strong) RTReviewAddItemDirector* addItemDirector;

@property (nonatomic, strong) NSMutableArray* arr_items;

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIButton* button_addItem;

- (IBAction)addItemButtonClicked:(id)sender;

- (IBAction)showConfigVC:(id)sender;

- (void)prepareData;
@end

@implementation ItemListTableViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.arr_items = [NSMutableArray array];
        self.addItemDirector = [RTReviewAddItemDirector new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.title = NSLocalizedString(@"HomeVCTitle", nil);
    
    self.dayID = [DateUtils getTodayDateId];
    //init,prepare data
    [[ReviewFacade sharedInstance] load];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self prepareData];
    });
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
    
    self.button_addItem = [UIButton buttonWithType:UIButtonTypeCustom];
    float width_button = 100;
    float height_button = 100;
    self.button_addItem.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - width_button) / 2.0, CGRectGetHeight(self.view.bounds) - height_button, width_button, height_button);
//    self.button_addItem.backgroundColor = [UIColor redColor];
    self.button_addItem.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.button_addItem setBackgroundImage:[UIImage imageNamed:@"icon_plus.png"] forState:UIControlStateNormal];
    [self.button_addItem addTarget:self action:@selector(addItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.button_addItem];
    
    UIBarButtonItem* buttonItem_config = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showConfigVC:)];
    self.navigationItem.rightBarButtonItem = buttonItem_config;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.arr_items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = @"list";
    ItemListCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell)
    {
        // Configure the cell...
        cell = [[ItemListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    ReviewItem* item = [self.arr_items objectAtIndex:indexPath.row];
    
    //考虑用图片去填充
//    cell.textLabel.text = [NSString stringWithFormat:@"%d", item.dateId_created];
    cell.info = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReviewItem* item = [self.arr_items objectAtIndex:indexPath.row];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray* arr_images = [NSMutableArray array];
        for (NSInteger i = 1; i <= item.count_images; i++)
        {
            UIImage* image = [item getImageAtIndex:i];
            if (image)
            {
                MJPhoto* photo = [MJPhoto new];
                photo.image = image;
                photo.index = i - 1;
                [arr_images addObject:photo];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (0 != arr_images.count)
            {
                MJPhotoBrowser* browser = [[MJPhotoBrowser alloc]init];
                browser.photos = arr_images;
                browser.currentPhotoIndex = 0;
                browser.info = item;
                browser.delegate = self;
                browser.canReview = YES;
                [browser show];
            }
        });
    });
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSInteger row = indexPath.row;
        ReviewItem* item = [self.arr_items objectAtIndex:row];
        BOOL result = [[ReviewFacade sharedInstance] deleteItemByID:item.id_review];
        if (result)
        {
            [self.arr_items removeObject:item];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self prepareData];
            [self.tableView reloadData];
        }
        else
        {
            
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - MJPhotoBrowserDelegate
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didClickReviewButtonAtIndex:(NSUInteger)index
{
    ReviewItem* item = photoBrowser.info;
    [[ReviewFacade sharedInstance] reviewItem:item];
    [[ReviewFacade sharedInstance] refreshForItem:item];
    [self prepareData];
    [self.tableView reloadData];
    NSURL* url_sound = [NSURL URLWithString:@"file:///System/Library/Audio/UISounds/Modern/sms_alert_circles.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url_sound,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark -
- (IBAction)addItemButtonClicked:(id)sender
{
    [MobClick event:event_click_add];
    __weak ItemListTableViewController* weakself = self;
    self.addItemDirector = [[RTReviewAddItemDirector alloc]init];
    self.addItemDirector.succBlock = ^(void){
        [[ReviewFacade sharedInstance] refresh];
        [weakself prepareData];
        [weakself.tableView reloadData];
        NSLog(@"success");
    };
    self.addItemDirector.failBlock = ^(void)
    {
        NSLog(@"failed");
    };
    self.addItemDirector.rootViewController = self;
    [self.addItemDirector action];
}

- (void)prepareData
{   
    [[ReviewFacade sharedInstance] refresh];
    self.arr_items = [NSMutableArray arrayWithArray:[[ReviewFacade sharedInstance] getReviewItemsForDayID:self.dayID]];
//    [self.tableView reloadData];
}

#pragma mark - UIViewControllerDelegate
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - IBAction

- (IBAction)showConfigVC:(id)sender
{
    ConfigTableViewController* configVC = [[ConfigTableViewController alloc]initWithNibName:@"ConfigTableViewController" bundle:nil];
    [self.navigationController pushViewController:configVC animated:YES];
}
@end
