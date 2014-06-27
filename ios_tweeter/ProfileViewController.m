//
//  ProfileViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/26/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileBannerView.h"
#import "ComposeViewController.h"

static NSString *kCellProfileImageClicked = @"CellProfileImageClicked";

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ProfileBannerView *profileBannerView;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onNewTweet:(id)sender;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadProfile:)
                                                     name:kCellProfileImageClicked
                                                   object:nil];    }
    return self;
}

- (void) loadProfile:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kCellProfileImageClicked]){
        NSDictionary* userInfo = notification.userInfo;
        self.user = [userInfo objectForKey:@"profileImageClicked"];

        NSLog (@"Notification is successfully received! %@",self.user.name);
        [self refreshView];
    }
}

- (void)refreshView
{
    self.tweetCountLabel.text = [NSString stringWithFormat: @"%ld",self.user.tweetCount];
    
    self.followersCountLabel.text = [NSString stringWithFormat: @"%ld",self.user.followerCount];
    
    self.followingCountLabel.text = [NSString stringWithFormat: @"%ld",self.user.followingCount];
    self.profileBannerView.user = self.user;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackButton:(id)sender {
      [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onNewTweet:(id)sender {
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
}
@end
