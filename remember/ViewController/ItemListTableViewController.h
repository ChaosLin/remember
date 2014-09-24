//
//  ItemListTableViewController.h
//  remember
//
//  Created by Chaos Lin on 8/29/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemListTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) NSInteger dayID;
@end
