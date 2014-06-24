//
//  ComposeViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterClient.h"
#import "User.h"
#import "Tweet.h"

@interface ComposeViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *tweetTextView;

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileTweetHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *textCountLabel;


- (IBAction)onTweetButtonClicked:(id)sender;
- (IBAction)onCancelButtonClicked:(id)sender;

@end
