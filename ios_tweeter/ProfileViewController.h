//
//  ProfileViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/26/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "ListViewController.h"

@protocol ProfileViewControllerDelegate <NSObject>

@optional

- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end


@interface ProfileViewController : UIViewController
@property (nonatomic, assign) id<ProfileViewControllerDelegate> delegate;
@property (weak, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIButton *hbButton;

@end
