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

static NSString *kCellProfileImageClicked = @"CellProfileImageClicked";

@interface TweetCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetedByLabelHeight;

- (IBAction)ProfileImageHiddenButtonClicked:(id)sender;

@end



@implementation TweetCell



- (void)awakeFromNib
{
    // Initialization code
}


- (void) initializeWithValues:(Tweet*)tweet{
    self.tweet = tweet;
  
    
    // in Case of retweeted
    if (tweet.orignalTweet) {
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted",  tweet.user.name];
         self.retweetedByLabelHeight.constant = 15 ;
        tweet = self.tweet.orignalTweet;
    }
    else{
        
        self.retweetedByLabelHeight.constant = 0 ;
        
    }
    
    
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
    
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark -- Button events

- (IBAction)onReplyClick:(id)sender {
// we actually handle the reply button clicked events in ListViewController.m itself    
 
}

- (IBAction)onRetweetClick:(id)sender {
    
    
    Tweet *tweet = self.tweet;
    // in Case of retweeted
    if (self.tweet.orignalTweet) {
        tweet = self.tweet.orignalTweet;
    }
    

    
    //toggle the state and button images
    if (tweet.retweeted) {
//        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
//        tweet.retweetCount--;
        if (tweet.retweeted) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Undo a Retweet not implemented yet"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            [alert show];
            return;
        }
    } else {
        [self retweetMe];
        
        tweet.retweetCount++;
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    }
    tweet.retweeted = !tweet.retweeted;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld",(long)tweet.retweetCount];
}

- (IBAction)onFavButtonClick:(id)sender {
    
    Tweet *tweet = self.tweet;
    // in Case of retweeted
    if (self.tweet.orignalTweet) {
        tweet = self.tweet.orignalTweet;
    }
    
    if (tweet.favorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_default"] forState:UIControlStateNormal];
        tweet.favoriteCount--;
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
        tweet.favoriteCount++;
    }
    
    tweet.favorited = !tweet.favorited;
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld",(long)tweet.favoriteCount];
    [self toggleFavorite];

}


-(void) toggleFavorite{
    TwitterClient *client = [TwitterClient instance];
    Tweet *t ;
    t =  self.tweet.orignalTweet ? self.tweet.orignalTweet : self.tweet;
    [client toggleFavoriteForTweet:t success:^(Tweet *t) {
        NSLog(@"fav good");
    } failure:^(NSError *error) {
        NSLog(@"fav bad %@",error.description);
    }];
}

-(void) retweetMe{
    
    TwitterClient *client = [TwitterClient instance];
    [client retweet:self.tweet success:^(Tweet *tweet) {
        NSLog(@"retweet good");
                tweet.retweeted=YES;
    } failure:^(NSError *error) {
        NSLog(@"retweet BAd %@",error.description);
    }];
}


//Load the profile View.. This transparent button is actually on top of imageView
- (IBAction)ProfileImageHiddenButtonClicked:(id)sender {
    
    NSLog(@"Image clicked");
    // Send tweet object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.tweet.user forKey:@"profileImageClicked"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kCellProfileImageClicked
     object:self userInfo:userInfo];
}
@end
