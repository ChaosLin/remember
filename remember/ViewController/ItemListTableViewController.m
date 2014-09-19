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

@interface ItemListTableViewController ()<MJPhotoBrowserDelegate>

@end

@implementation ItemListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray* arr_items = [[ReviewFacade sharedInstance] getReviewItemsForDayID:self.dayID];
    return arr_items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = @"list";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if (!cell)
    {
        // Configure the cell...
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    }
    
    NSArray* arr_items = [[ReviewFacade sharedInstance] getReviewItemsForDayID:self.dayID];
    ReviewItem* item = [arr_items objectAtIndex:indexPath.row];
    
    //考虑用图片去填充
    cell.textLabel.text = [NSString stringWithFormat:@"%d", item.dateId_created];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* arr_items = [[ReviewFacade sharedInstance] getReviewItemsForDayID:self.dayID];
    ReviewItem* item = [arr_items objectAtIndex:indexPath.row];
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
        NSArray* arr_items = [[ReviewFacade sharedInstance] getReviewItemsForDayID:self.dayID];
        ReviewItem* item = [arr_items objectAtIndex:row];
        BOOL result = [[ReviewFacade sharedInstance] deleteItemByID:item.id_review];
        if (result)
        {
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    [self.tableView reloadData];
}
@end
