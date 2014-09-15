//
//  RTReviewAddItemDirector.h
//  remember
//
//  Created by Chaos Lin on 8/28/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import "RTDirector.h"

typedef void (^DirectorSuccBlock)(void);
typedef void (^DirectorFailBlock)(void);

@interface RTReviewAddItemDirector:NSObject<RTDirector>
@property (nonatomic, copy) DirectorSuccBlock succBlock;
@property (nonatomic, copy) DirectorFailBlock failBlock;
@property (nonatomic, weak) UIViewController* rootViewController;
@end
