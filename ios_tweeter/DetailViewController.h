//
//  DetailViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/20/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface DetailViewController : UIViewController <UITextViewDelegate>
//@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageVIew;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetedByLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;


@property (weak, nonatomic) IBOutlet UITextView *tweetContentView;

@property (weak, nonatomic) IBOutlet UIWebView *tweetWebView;



@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) NSMutableArray* tweets;



- (IBAction)onBackClicked:(id)sender;
- (IBAction)onReplyClicked:(id)sender;
- (IBAction)onReplySmallClicked:(id)sender;
- (IBAction)onRetweetButtonClicked:(id)sender;
- (IBAction)onfavoriteButtonClicked:(id)sender;

@end
