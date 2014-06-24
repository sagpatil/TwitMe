//
//  ComposeViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ComposeViewController.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

static int TweetLength = 140;
static NSString *replyNotification = @"replyTweet";

@interface ComposeViewController ()
@property (nonatomic,assign) unsigned long textCount;
@end

@implementation ComposeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tweetNotificationReceived:)
                                                     name:replyNotification
                                                   object:nil];

    
    }
    return self;
}

- (void) tweetNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:replyNotification]){
        NSDictionary* userInfo = notification.userInfo;
        NSString *replyTo = [userInfo objectForKey:@"reply"];
         NSLog (@"Notification is successfully received! %@",replyTo);
        self.tweetTextView.text = [NSString stringWithFormat:@"@%@",replyTo];
        self.textCount = self.tweetTextView.text.length;
        self.textCountLabel.text = [NSString stringWithFormat:@"%ld",TweetLength-self.tweetTextView.text.length];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Code to hide Status Bar
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
    else
    {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    
    User* currentUser = [User currentUser];
    self.profileNameLabel.text = currentUser.name;
    self.profileTweetHandleLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
    [self.profileImageView setImageWithURL:currentUser.profileImageURL];
    
    [self.tweetTextView becomeFirstResponder];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTweetButtonClicked:(id)sender {
    if(self.tweetTextView.text.length >0){
        TwitterClient *client = [TwitterClient instance];
        NSDictionary *parameters = [[NSDictionary alloc]initWithObjectsAndKeys:self.tweetTextView.text,@"status", nil];
        [client postTweetWithSuccess:parameters sucess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"tweet posted ");
            [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Tweet post failed %@",error.description);
        }];
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Tweet Posted" object:self];
    
}

- (IBAction)onCancelButtonClicked:(id)sender {
    
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


-(IBAction)textViewDidChange:(UITextView *)textView{
    
    //logic for displaying the remaining char count on text change
    
    if(textView == self.tweetTextView)
    {
        unsigned long currCharCount = self.tweetTextView.text.length;
        if (self.textCount < currCharCount)
            self.textCount++;
        else
            self.textCount--;
        
        
        if (TweetLength < currCharCount) {
            NSString *text = self.tweetTextView.text;
            text = [text substringToIndex:text.length - 1];
            self.tweetTextView.text= text;
            self.textCount = self.tweetTextView.text.length;
        }
        else
            self.textCountLabel.text = [NSString stringWithFormat:@"%ld",TweetLength-self.textCount];
        
    }
    
}
@end
