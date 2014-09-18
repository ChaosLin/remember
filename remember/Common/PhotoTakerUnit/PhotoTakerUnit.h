//
//  PhotoTakerUnit.h
//  remember
//
//  Created by Chaos Lin on 9/12/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTDirector.h"

typedef void (^PhotoTakerSuccBlock)(NSArray* arr_images);
typedef void (^PhotoTakerFailedBlock)(NSError* error);

@interface PhotoTakerUnit : NSObject<RTDirector>

@property (nonatomic, strong) NSArray* arr_imagesTaken;
@property (nonatomic, weak) UIViewController* rootViewController;
@property (nonatomic, copy) PhotoTakerSuccBlock succBlock;
@property (nonatomic, copy) PhotoTakerFailedBlock failBlock;
@property (nonatomic, assign) NSInteger maxNumToTake;//the max number to take

- (instancetype)initWithRootViewController:(UIViewController*)rootViewController succBlock:(PhotoTakerSuccBlock)succBlock failBlock:(PhotoTakerFailedBlock)failBlock maxNumToTake:(NSInteger)maxNum;
@end
