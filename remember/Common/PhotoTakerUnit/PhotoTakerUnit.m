//
//  PhotoTakerUnit.m
//  remember
//
//  Created by Chaos Lin on 9/12/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "PhotoTakerUnit.h"

@interface PhotoTakerUnit()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController* imagePickerController;
@property (nonatomic, strong) NSMutableArray* arr_images;

- (IBAction)takePicButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
@end

@implementation PhotoTakerUnit

- (instancetype)init
{
    return [self initWithRootViewController:nil succBlock:nil failBlock:nil maxNumToTake:1];
}

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController succBlock:(PhotoTakerSuccBlock)succBlock failBlock:(PhotoTakerFailedBlock)failBlock maxNumToTake:(NSInteger)maxNum
{
    if (self = [super init])
    {
        self.rootViewController = rootViewController;
        self.succBlock = succBlock;
        self.failBlock = failBlock;
        self.maxNumToTake = 1;
        self.arr_images = [NSMutableArray arrayWithCapacity:6];
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - RTDirector
- (void)action
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:@"不支持的设备" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alertView show];
        self.failBlock(nil);
        return;
    }
    self.imagePickerController = [[UIImagePickerController alloc]init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self.rootViewController presentViewController:self.imagePickerController animated:YES completion:^{
        
    }];
}

- (void)gameOver
{
    if (self.rootViewController)
    {
        [self.rootViewController dismissViewControllerAnimated:YES completion:^(void){
            
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //get image
    UIImage* image = nil;
    //add to arr
    if (image)
    {
        [self.arr_images addObject:image];
    }
    
    //if count >= max succ
    if (self.arr_images.count >= self.maxNumToTake)
    {
        self.succBlock(self.arr_images);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    self.failBlock(nil);
}

//用户主动关闭
- (void)imagePickerControllerDidFinishehPickImages
{
    if (0 < self.arr_images.count)
    {
        self.succBlock(self.arr_images);
    }
    else
    {
        self.failBlock(nil);
    }
}

#pragma mark - UIButton action

- (IBAction)takePicButtonClicked:(id)sender
{
    [self.imagePickerController takePicture];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{
        self.failBlock(nil);
    }];
}
@end
