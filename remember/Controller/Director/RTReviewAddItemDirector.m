//
//  RTReviewAddItemDirector.m
//  remember
//
//  Created by Chaos Lin on 8/28/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "RTReviewAddItemDirector.h"
#import "AGImagePickerController.h"
#import "ReviewItem.h"
#import "ReviewFacade.h"
#import "MJPhoto.h"

@interface RTReviewAddItemDirector()
@property (nonatomic, strong) AGImagePickerController* imagePickerController;
@property (nonatomic, strong) ReviewItem* item;

- (void)createReviewItem;
- (void)insertIntoReviewItemWithImages:(NSArray*)images;
@end


@implementation RTReviewAddItemDirector

- (void)action
{
    //生成Item
    [self createReviewItem];
    
    //开始选图
    __weak RTReviewAddItemDirector* weakSelf = self;
    self.imagePickerController = [[AGImagePickerController alloc]initWithDelegate:nil failureBlock:^(NSError *error) {
            [weakSelf.rootViewController dismissViewControllerAnimated:YES completion:^(void)
            {
                if (weakSelf.failBlock)
                {
                    weakSelf.failBlock();
                }
            }];
    } successBlock:^(NSArray *info) {
        //注意把ALSet转成UIImage
        [weakSelf.rootViewController dismissViewControllerAnimated:YES completion:^(void){
            weakSelf.imagePickerController = nil;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                NSMutableArray* arr_images = [NSMutableArray arrayWithCapacity:6];
                for (ALAsset* set in info)
                {
                    ALAssetRepresentation* presentation = [set defaultRepresentation];
                    UIImage* image = [UIImage imageWithCGImage:[presentation fullScreenImage] scale:presentation.scale orientation:UIImageOrientationUp];
                    MJPhoto* photo = MJPhoto.new;
                    photo.image = image;
                    [arr_images addObject:photo];
                }
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [weakSelf insertIntoReviewItemWithImages:arr_images];
                });
            });
        }];

    } maximumNumberOfPhotosToBeSelected:6 shouldChangeStatusBarStyle:YES toolbarItemsForManagingTheSelection:nil andShouldShowSavedPhotosOnTop:YES];
    [self.rootViewController presentViewController:self.imagePickerController animated:YES completion:nil];
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
    BOOL result = [self.item addImages:images];
    if (result)
    {
        BOOL result_addItem = [[ReviewFacade sharedInstance] addItem:self.item];
        if (result_addItem)
        {
            if (self.succBlock)
            {
                self.succBlock();
            }
        }
    }
    else
    {
        if (self.failBlock)
        {
            self.failBlock();
        }
    }
    
}
@end
