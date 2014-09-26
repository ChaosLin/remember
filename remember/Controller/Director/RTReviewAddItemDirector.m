//
//  RTReviewAddItemDirector.m
//  remember
//
//  Created by Chaos Lin on 8/28/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "RTReviewAddItemDirector.h"
#import "AGImagePickerController.h"
#import "PhotoTakerUnit.h"
#import "ReviewItem.h"
#import "ReviewFacade.h"
#import "MJPhoto.h"
#import "RTLoadingView.h"

@interface RTReviewAddItemDirector() <UIActionSheetDelegate>
@property (nonatomic, strong) AGImagePickerController* imagePickerController;
@property (nonatomic, strong) ReviewItem* item;
@property (nonatomic, strong) PhotoTakerUnit* photoUit;

- (void)createReviewItem;
- (void)insertIntoReviewItemWithImages:(NSArray*)images;

- (void)takeImageFromCamera;
- (void)takeImageFromAlbum;
@end


@implementation RTReviewAddItemDirector

- (void)action
{
    //生成Item
    [self createReviewItem];
    
    UIActionSheet* action = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照", @"从相机选择", nil];
    [action showInView:self.rootViewController.view];
}

- (void)gameOver
{
    self.imagePickerController = nil;
}

#pragma mark - 自定义

- (void)createReviewItem
{
    self.item = [[ReviewItem alloc]init];
}

- (void)insertIntoReviewItemWithImages:(NSArray*)images
{
    [RTLoadingView showInView:self.rootViewController.view];
    __weak RTReviewAddItemDirector* weakSelf = self;
    [self.item addImages:images finished:^(BOOL success, NSError *error) {
        if (success)
            {
                BOOL result_addItem = [[ReviewFacade sharedInstance] addItem:weakSelf.item];
                if (result_addItem)
                {
                    if (weakSelf.succBlock)
                    {
                        weakSelf.succBlock();
                        [RTLoadingView closeFromView:weakSelf.rootViewController.view];
                    }
                }
            }
            else
            {
                if (weakSelf.failBlock)
                {
                    weakSelf.failBlock();
                    [RTLoadingView closeFromView:weakSelf.rootViewController.view];
                }
            }
    }];
}

#pragma mark - 取图

- (void)takeImageFromCamera
{
    __weak RTReviewAddItemDirector* weakSelf = self;
    self.photoUit = [[PhotoTakerUnit alloc]initWithRootViewController:self.rootViewController succBlock:^(NSArray *arr_images) {
        [weakSelf insertIntoReviewItemWithImages:arr_images];
        [MobClick endEvent:event_addItemFromCamera];
        [MobClick event:event_addItemFromCamera attributes:@{@"result":SuccString}];
    } failBlock:^(NSError *error) {
        if (self.failBlock)
        {
            self.failBlock();
            [MobClick endEvent:event_addItemFromCamera];
            [MobClick event:event_addItemFromCamera attributes:@{@"result":FailString}];
        }
    } maxNumToTake:6];
    [self.photoUit action];
}

- (void)takeImageFromAlbum
{
    //开始选图
    __weak RTReviewAddItemDirector* weakSelf = self;
    self.imagePickerController = [[AGImagePickerController alloc]initWithDelegate:nil failureBlock:^(NSError *error) {
        [weakSelf.rootViewController dismissViewControllerAnimated:YES completion:^(void)
         {
             if (weakSelf.failBlock)
             {
                 weakSelf.failBlock();
             }
             [MobClick event:event_addItemFromAlbum attributes:@{@"result":FailString}];
             [MobClick endEvent:event_addItemFromAlbum];
         }];
    } successBlock:^(NSArray *info) {
        //注意把ALSet转成UIImage
        [weakSelf.rootViewController dismissViewControllerAnimated:YES completion:^(void){
            weakSelf.imagePickerController = nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                NSMutableArray* arr_images = [NSMutableArray arrayWithCapacity:6];
                NSMutableArray* arr_photos = [NSMutableArray arrayWithCapacity:6];
                for (ALAsset* set in info)
                {
                    ALAssetRepresentation* presentation = [set defaultRepresentation];
                    UIImage* image = [UIImage imageWithCGImage:[presentation fullScreenImage] scale:presentation.scale orientation:UIImageOrientationUp];
                    MJPhoto* photo = MJPhoto.new;
                    photo.image = image;
                    [arr_photos addObject:photo];
                    [arr_images addObject:image];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [weakSelf insertIntoReviewItemWithImages:arr_images];
                    [MobClick event:event_addItemFromAlbum attributes:@{@"result":SuccString}];
                    [MobClick endEvent:event_addItemFromAlbum];
                });
            });
        }];
        
    } maximumNumberOfPhotosToBeSelected:6 shouldChangeStatusBarStyle:YES toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:YES];
    [self.rootViewController presentViewController:self.imagePickerController animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == buttonIndex)
    {
        [MobClick event:event_click_camera];
        [MobClick beginEvent:event_addItemFromCamera];
        [self takeImageFromCamera];
    }
    else if (1 == buttonIndex)
    {
        [MobClick event:event_click_album];
        [MobClick beginEvent:event_addItemFromAlbum];
        [self takeImageFromAlbum];
    }
}

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    self.failBlock();
}
@end
