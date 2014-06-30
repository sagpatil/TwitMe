//
//  HBViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/29/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HBViewControllerDelegate <NSObject>

@optional
- (void)imageSelected:(UIImage *)image withTitle:(NSString *)imageTitle withCreator:(NSString *)imageCreator;

@required
- (void)loadVC:(int)vc;
- (void)loadCustom;

@end

@interface HBViewController : UIViewController
@property (nonatomic, assign) id<HBViewControllerDelegate> delegate;
@end
