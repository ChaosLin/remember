//
//  AppDelegate.m
//  remember
//
//  Created by RentonTheUncoped on 14-8-18.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import "AppDelegate.h"
//#import "HomeViewController.h"
#import "ItemListTableViewController.h"
#import "ReviewFacade.h"
#import "MobClick.h"
#import "CommonConfig.h"

@interface AppDelegate()
- (void)registerUmeng;
- (void)getUmengTestInfo;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self registerUmeng];
    
    [self getUmengTestInfo];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    ItemListTableViewController* homeVC = [[ItemListTableViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController* navigationVC = [[UINavigationController alloc]initWithRootViewController:homeVC];
    self.window.rootViewController = navigationVC;
    
    [ReviewFacade sharedInstance];
    
    [self.window makeKeyAndVisible];
    
    [self test];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UMeng Method
- (void)registerUmeng
{
    [MobClick startWithAppkey:UMENG_KEY reportPolicy:SEND_INTERVAL channelId:UMENG_ChannelID];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
}

- (void)getUmengTestInfo
{
        Class cls = NSClassFromString(@"UMANUtil");
        SEL deviceIDSelector = @selector(openUDIDString);
        NSString *deviceID = nil;
        if(cls && [cls respondsToSelector:deviceIDSelector]){
            deviceID = [cls performSelector:deviceIDSelector];
        }
        NSLog(@"{\"oid\": \"%@\"}", deviceID);
}

- (void)test
{
    //    CKContainer* container = [CKContainer defaultContainer];
    //    CKDatabase* dataBase = [container publicCloudDatabase];
    //    CKRecordID* recordID = [[CKRecordID alloc]initWithRecordName:@"TestID"];
    //    CKRecord* record = [[CKRecord alloc]initWithRecordType:@"TestUnit" recordID:recordID];
    //
    //    record[@"key1"] = @"22";
    //    [dataBase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
    //        if (error)
    //        {
    //            NSLog(@"%@", error);
    //        }
    //        else
    //        {
    //            id sth = record;
    //            NSLog(@"%@", sth);
    //        }
    //    }];
    //    [dataBase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
    //        if (error)
    //        {
    //            NSLog(@"%@", error);
    //        }
    //        else
    //        {
    //            NSLog(@"%@", record);
    //
    //
    //            UIImage* image_test = [UIImage imageNamed:@"LaunchImage"];
    //            NSData* data_image = UIImageJPEGRepresentation(image_test, 1);
    //            NSURL* url_path = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"testImage.jpeg"]];
    //            [data_image writeToURL:url_path atomically:YES];
    //            CKAsset* asset = [[CKAsset alloc]initWithFileURL:url_path];
    //            record[@"image"] = asset;
    //            [dataBase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
    //                if (error)
    //                {
    //                    NSLog(@"%@", error);
    //                }
    //                else
    //                {
    //                    id sth = record;
    //                    NSLog(@"%@", sth);
    //                }
    //            }];
    //        }
    //    }];
    
    
    //    UILocalNotification* notification = [[UILocalNotification alloc]init];
    //    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    //    notification.alertBody = [NSString stringWithFormat:@"%@", [[NSDate date] description]];
    //    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
@end
