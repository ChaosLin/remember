//
//  PhotoTakerUnit.m
//  remember
//
//  Created by Chaos Lin on 9/12/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "PhotoTakerUnit.h"

@interface PhotoTakerUnit()<UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImagePickerController* imagePickerController;
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
    }
    return self;
}

- (void)dealloc
{
    
}

#pragma mark - RTDirector
- (void)action
{
    
}

- (void)gameOver
{
    self.imagePickerController = nil;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
}
@end
