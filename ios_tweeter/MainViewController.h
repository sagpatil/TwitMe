//
//  MainViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/29/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListViewController.h"
#import "ProfileViewController.h"
#import "HBViewController.h"


typedef NS_ENUM(NSInteger, VcType) {
    TimeLineVC,
    ProfileVC,
    MentionsVC
};

@interface MainViewController : UIViewController <ListViewControllerDelegate,HBViewControllerDelegate>
@property (nonatomic, strong) UIViewController *currentViewController;
@end
