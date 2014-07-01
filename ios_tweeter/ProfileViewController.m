//
//  ProfileViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/26/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileBannerView.h"
#import "TweetCell.h"
#import "ComposeViewController.h"


static NSString *kCellProfileImageClicked = @"CellProfileImageClicked";
static NSString *kHBbuttonCLicked = @"HBbuttonClick";

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ProfileBannerView *profileBannerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)onBackButton:(id)sender;
- (IBAction)onNewTweet:(id)sender;

@property (strong, nonatomic) NSMutableArray* tweets;
@property(strong,nonatomic) TweetCell *stubCell;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(loadProfile:)
                                                     name:kCellProfileImageClicked
                                                   object:nil];
        
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFlag:) name:kHBbuttonCLicked object:nil];
    }
    return self;
}

- (void) loadProfile:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kCellProfileImageClicked]){
        NSDictionary* userInfo = notification.userInfo;
        self.user = [userInfo objectForKey:@"profileImageClicked"];
        [self refreshView];
    }
}




- (void)refreshView
{
    self.tweetCountLabel.text = [NSString stringWithFormat: @"%d",self.user.tweetCount];
    
    self.followersCountLabel.text = [NSString stringWithFormat: @"%d",self.user.followerCount];
    
    self.followingCountLabel.text = [NSString stringWithFormat: @"%d",self.user.followingCount];
    self.profileBannerView.user = self.user;
    [self getUserTimeline];
    
    self.titleLabel.text = self.user == [User currentUser]  ? @"ME" : @"profile";
        
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Profile VC did load");
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UINib *customNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"TweetCell"];
    self.stubCell= [self.tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell initializeWithValues:self.tweets[indexPath.row]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.stubCell initializeWithValues:self.tweets[indexPath.row]];
    [self.stubCell layoutSubviews];
    
    CGSize size = [_stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
    
}



- (IBAction)onBackButton:(id)sender {
    if(self.user.userId != [User currentUser].userId)
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    else
    {
        self.comingFromHBVC = NO;
        UIButton *button = sender;
        switch (button.tag) {
            case 0: {
                NSLog(@"HBTapped profile 0 ");
                [_delegate movePanelToOriginalPosition];
                break;
            }
                
            case 1: {
                NSLog(@"HBTapped profile 1");
                [_delegate movePanelRight];
                break;
            }
                
        }
	}
}

- (IBAction)onNewTweet:(id)sender {
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
}


- (void) getUserTimeline{
    
    TwitterClient *client = [TwitterClient instance];
    NSDictionary *param = @{@"screen_name":self.user.screenName };
    
    [client userTimelineWithSuccess:param
                            success:^(NSArray *tweets) {
                                self.tweets = [[NSMutableArray alloc]initWithArray:tweets];
                                [self.tableView reloadData];
                                NSLog(@"Success Loading tweets %lu",(unsigned long)self.tweets.count);
                                
                            } failure:^(NSError *error) {
                                NSLog(@"Falied timeline loading");
                                
                            }];
    
}
@end
