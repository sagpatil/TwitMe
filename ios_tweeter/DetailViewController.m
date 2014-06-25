//
//  DetailViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/20/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "DetailViewController.h"
#import "ComposeViewController.h"
#import "ListViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>


static NSString *clickNotification = @"showDetail";
static NSString *replyNotification = @"replyTweet";

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *retweetedByHeight;
@property (assign, nonatomic) long index;

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tweetNotificationReceived:)
                                                     name:clickNotification
                                                   object:nil];
    }
    return self;
}

- (void) tweetNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:clickNotification]){
        NSDictionary* userInfo = notification.userInfo;
        self.tweets = [userInfo objectForKey:@"tweet"];
        NSIndexPath *current = [userInfo objectForKey:@"index"];
        self.tweet = self.tweets[current.row];
        self.index = current.row;
        
       // NSLog (@"Notification is successfully received! %@",self.tweet.text);
        [self refreshView];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshView];
    
    
    UISwipeGestureRecognizer *swipeBack = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popView)];
    swipeBack.numberOfTouchesRequired = 1;
    swipeBack.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeBack];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(nextView)];
    swipeDown.numberOfTouchesRequired = 1;
    swipeDown.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(previousView)];
    swipeUp.numberOfTouchesRequired = 1;
    swipeUp.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeUp];
}

- (void)nextView
{
    if(self.index >= self.tweets.count - 1)
        return;
    
    self.index++;
    self.tweet = self.tweets[self.index];
   [self refreshView];
    
}

- (void)previousView
{
    if(self.index<1)
        return;
    
    self.index--;
    self.tweet = self.tweets[self.index];
    [self refreshView];
    
}

- (void)popView
{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)refreshView{
    
    
    Tweet *tweet = self.tweet;

    
    // in Case of retweeted set orignal tweet as the tweet to display data
    if (tweet.orignalTweet) {
        self.retweetedByLabel.text = [NSString stringWithFormat:@"%@ retweeted",  tweet.user.name];
        self.retweetedByHeight.constant = 15 ;
        tweet = self.tweet.orignalTweet;
    }
    else{
        
        self.retweetedByHeight.constant = 0 ;
        
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
    self.profileNameLabel.text = tweet.user.name;
    self.tweetHandleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tweetHandleLabel.numberOfLines = 0;
    self.tweetHandleLabel.text = [NSString stringWithFormat:@"@%@",  tweet.user.screenName];
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld FAVORITES",(long)tweet.favoriteCount];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld RETWEETS",(long)tweet.retweetCount];
    [self.profileImageVIew setImageWithURL:tweet.user.profileImageURL];
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy, hh:mm a"];
    self.createdAtLabel.text = [NSString stringWithFormat:@"%@",  [formatter stringFromDate:self.tweet.createdAt]];
   

    
}

#pragma mark View Button Events

- (IBAction)onBackClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onReplyClicked:(id)sender {
    
  
    
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
    
    // Send tweet object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.tweet.user.screenName forKey:@"reply"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:replyNotification
     object:self userInfo:userInfo];
}

- (IBAction)onReplySmallClicked:(id)sender {
    [self onReplyClicked:sender];
}

- (IBAction)onRetweetButtonClicked:(id)sender {
    Tweet *tweet = self.tweet;
    // in Case of retweeted tweet
    if (self.tweet.orignalTweet) {
        tweet = self.tweet.orignalTweet;
    }
    //toggle the state and button images
    if (tweet.retweeted) {
//        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_default"] forState:UIControlStateNormal];
//         tweet.retweetCount--;
        
        if (tweet.retweeted) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Undo a Retweet not implemented yet"
                                  message:nil
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles: nil];
            [alert show];
            return;
        }
        
    } else {
        [self retweetMe];
         tweet.retweetCount++;
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    }
    tweet.retweeted = !tweet.retweeted;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld RETWEETS",(long)tweet.retweetCount];
    //[self refreshView];
    
}

- (IBAction)onfavoriteButtonClicked:(id)sender {
    
   
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
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld FAVORITES",(long)tweet.favoriteCount];
    [self toggleFavorite];
   // [self refreshView];

    
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
   } failure:^(NSError *error) {
       
       NSLog(@"retweet BAd %@",error.description);
   }];
    
    
}
@end
