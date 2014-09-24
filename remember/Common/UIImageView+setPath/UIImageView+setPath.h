//
//  UIImageView+setPath.h
//  remember
//
//  Created by RentonTheUncoped on 14-9-23.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (setPath)

- (void)setImageWithPath:(NSString*)path;

- (void)setThumbnailImageWithPath:(NSString*)path size:(CGSize)size;
@end