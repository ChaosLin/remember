//
//  IntroductionView.h
//  remember
//
//  Created by RentonTheUncoped on 14/10/27.
//  Copyright (c) 2014年 Uncoped Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IntroductionView;

@protocol IntroductionViewDelegate <NSObject>
@required
- (NSInteger)numberOfPagesForIntroductionview:(IntroductionView*)indtroductionView;
//- (NSString*)currentIntroductionVersionForIntroductionView:(IntroductionView*)indtroductionView;
- (void)didClickNextButtonOfIntroductionView:(IntroductionView*)indtroductionView;;
@end

@interface IntroductionView : UIView
@property (nonatomic, weak) id<IntroductionViewDelegate> introductionDelegate;
- (void)reloadData;
//- (void)save;
//- (BOOL)checkIfNecessaryToShow;
@end
