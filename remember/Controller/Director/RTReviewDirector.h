//
//  RTReviewDirector.h
//  remember
//
//  Created by Chaos Lin on 8/28/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DirectorSuccBlock)(void);
typedef void (^DirectorFailBlock)(void);

@interface RTReviewDirector : NSObject

@property (nonatomic, copy) DirectorSuccBlock succBlock;
@property (nonatomic, copy) DirectorFailBlock failBlock;

- (void)action;
- (void)gameOver;
@end
