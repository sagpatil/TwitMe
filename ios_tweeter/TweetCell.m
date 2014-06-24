//
//  TweetCell.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "TweetCell.h"
#import "DateTools.h"
#import "ComposeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface TweetCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetedByLabelHeight;

@end



@implementation TweetCell



- (void)awakeFromNib
{
    // Initialization code
}


- (void) initializeWithValues:(Tweet*)tweet{
    self.tweet = tweet;
    
    if (tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_default"] forState:UIControlStateNormal];
    }
    
    if (tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
    }
    
    // in Case of retweeted
    if (tweet.orignalTweet) {
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted",  tweet.user.name];
         self.retweetedByLabelHeight.constant = 15 ;
        tweet = self.tweet.orignalTweet;
    }
    else{
        
        self.retweetedByLabelHeight.constant = 0 ;
        
    }
    
    
    self.tweetTextLabel.text = tweet.text;
    self.nameLabel.text = tweet.user.name;
    self.tweetHandleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tweetHandleLabel.numberOfLines = 0;
    self.tweetHandleLabel.text = [NSString stringWithFormat:@"@%@",  tweet.user.screenName];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld",(long)tweet.favoriteCount];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld",(long)tweet.retweetCount];
    [self.profileImageView setImageWithURL:tweet.user.profileImageURL];
    
    //Date formatting for getting x mins ago from dateTool Pod
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [tweet.createdAt timeIntervalSinceDate:currentDate];
    NSDate *timeAgoDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:currentDate];
    self.timeLabel.text = timeAgoDate.shortTimeAgoSinceNow;
    NSLog(@"Time Ago: %@  %@", timeAgoDate.shortTimeAgoSinceNow,tweet.idStr);

    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark -- Button events

- (IBAction)onReplyClick:(id)sender {
//#TODO Figure out how to display new VC on click on button in a cell
    
    //ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];

    
  //  [self presentViewController:newTweetVC animated:YES completion:nil];
    
}

- (IBAction)onRetweetClick:(id)sender {
    //toggle the state and button images
    if (self.tweet.retweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
        self.tweet.retweetCount--;
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
        self.tweet.retweetCount++;
}
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.retweetCount]; // update the label
    self.tweet.retweeted = !self.tweet.retweeted; // invert the flag
}

- (IBAction)onFavButtonClick:(id)sender {
    if (self.tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_default"] forState:UIControlStateNormal];
        self.tweet.favoriteCount--;
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
        self.tweet.favoriteCount++;
    }
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld",(long)self.tweet.favoriteCount];
    self.tweet.favorited = !self.tweet.favorited;
}


@end
