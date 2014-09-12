//
//  RTReviewDirector.h
//  remember
//
//  Created by Chaos Lin on 8/28/14.
//  Copyright (c) 2014 Uncoped Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RTDirector <NSObject>
@required
- (void)action;
- (void)gameOver;
@end
