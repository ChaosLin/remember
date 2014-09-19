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
- (IBAction)finishButtonClicked:(id)sender;
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
        self.maxNumToTake = 6;
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
    
    CGSize size_long = CGSizeMake(320, 96);
    CGSize size_short = CGSizeMake(320, 54);
    //overLayView
    CGSize toolBarSize = size_short;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight > 480) {
        toolBarSize = size_long;
    }
    
    UIView* cameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    UIView* toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight - toolBarSize.height, toolBarSize.width, toolBarSize.height)];
    toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //渐变色
    CGSize btnSize = CGSizeMake(62, 37);
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(9, (toolBarSize.height - btnSize.height) / 2, btnSize.width, btnSize.height);
    [cancelBtn addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"zhaoxiang_l_btn.png"] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [toolbarView addSubview:cancelBtn];
    
    CGSize pickBtnSize = CGSizeMake(102, 37);
    UIButton* pickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    pickBtn.frame = CGRectMake((320 - pickBtnSize.width) / 2, (toolBarSize.height - pickBtnSize.height) / 2, pickBtnSize.width, pickBtnSize.height);
//    [pickBtn setImage:[UIImage imageNamed:@"paizhao_btn.png"] forState:UIControlStateNormal];
    [pickBtn setBackgroundColor:[UIColor redColor]];
    [pickBtn addTarget:self action:@selector(takePicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:pickBtn];
    
    CGSize finishBtnSize = CGSizeMake(62, 37);
    UIButton* finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(250, (toolBarSize.height - finishBtnSize.height) / 2, finishBtnSize.width, finishBtnSize.height);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [toolbarView addSubview:finishBtn];
    
    [cameraOverlayView addSubview:toolbarView];
    self.imagePickerController.cameraOverlayView = cameraOverlayView;
    self.imagePickerController.showsCameraControls = NO;
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
    UIImage* image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //add to arr
    if (image)
    {
        [self.arr_images addObject:image];
    }
    
    //if count >= max succ
    if (self.arr_images.count >= self.maxNumToTake)
    {
        [self.rootViewController dismissViewControllerAnimated:YES completion:^{
            self.succBlock(self.arr_images);
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{
        self.failBlock(nil);
    }];
}

//用户主动关闭
- (void)imagePickerControllerDidFinishehPickImages
{
    if (0 < self.arr_images.count)
    {
        [self.rootViewController dismissViewControllerAnimated:YES completion:^{
            self.succBlock(self.arr_images);
        }];
    }
    else
    {
        [self.rootViewController dismissViewControllerAnimated:YES completion:^{
            self.failBlock(nil);
        }];
    }
}

#pragma mark - UIButton action

- (IBAction)takePicButtonClicked:(id)sender
{
    [self.imagePickerController.view setAlpha:1];
    [self.imagePickerController takePicture];
    [UIView animateWithDuration:0.1 animations:^{
        self.imagePickerController.view.alpha = 0;
    } completion:^(BOOL finished) {
        self.imagePickerController.view.alpha = 1;
    }];
}

- (IBAction)cancelButtonClicked:(id)sender
{
    [self.rootViewController dismissViewControllerAnimated:YES completion:^{
        self.failBlock(nil);
    }];
}

- (IBAction)finishButtonClicked:(id)sender
{
    [self imagePickerControllerDidFinishehPickImages];
}
@end
