//
//  ListViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "ListViewController.h"
#import "TweetCell.h"
#import "DetailViewController.h"
#import "ComposeViewController.h"
#import "ProfileViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "Tweet.h"
#import "MBProgressHUD.h"

static NSString *clickNotification = @"showDetail";
static NSString *replyNotification = @"replyTweet";
static NSString *newTweetNotification = @"newTweet";
static NSString *kCellProfileImageClicked = @"CellProfileImageClicked";

@interface ListViewController ()
@property(strong,nonatomic) TweetCell *stubCell;
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) NSString* lastTweetId; // tweet id of last row in table. will be sent to get the older tweets for infinite scrolling

- (IBAction)onNewTweetTapped:(id)sender;
- (IBAction)onHBTapped:(id)sender;

@end


//////////////////////////////////////////////////////////////////////////////////////

// Tihs is used to get a superview in order to get the reply button in the tableViewCewll to genetrate an event for showing a new ViewController for compose

@interface UIView (SuperView)

- (UIView *)findSuperViewWithClass:(Class)superViewClass;

@end

@implementation UIView (SuperView)

- (UIView *)findSuperViewWithClass:(Class)superViewClass {
    
    UIView *superView = self.superview;
    UIView *foundSuperView = nil;
    
    while (nil != superView && nil == foundSuperView) {
        if ([superView isKindOfClass:superViewClass]) {
            foundSuperView = superView;
        } else {
            superView = superView.superview;
        }
    }
    return foundSuperView;
}
@end

//////////////////////////////////////////////////////////////////////////////////////


@implementation ListViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tweetNotificationReceived:) name:newTweetNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProfile:) name:kCellProfileImageClicked object:nil];

    }
    return self;
}


// Get Notification of new tweet posted and the update the TableView locally 
- (void) tweetNotificationReceived:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:newTweetNotification]){
        NSDictionary* userInfo = notification.userInfo;
        Tweet *newTweet = [userInfo objectForKey:@"newTweet"];
        NSLog (@"Notification is successfully received! %@",newTweet.text);
        [self.tweets insertObject:newTweet atIndex:0];
        [self.tabelView reloadData];
    }
}


- (void) showProfile:(NSNotification *) notification
{ NSDictionary* userInfo = notification.userInfo;
    User *user = [userInfo objectForKey:@"profileImageClicked"];
    
    NSLog (@"Notification is successfully received in ListView %@",user.name);
    
    
    ProfileViewController *profileVC = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    profileVC.user = user;
    [self presentViewController:profileVC animated:YES completion:nil];

}

- (void)viewDidLoad
{

    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSLog(@"List View Did Load");
    self.tabelView.dataSource = self;
    self.tabelView.delegate = self;
    
    UINib *customNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tabelView registerNib:customNib forCellReuseIdentifier:@"TweetCell"];
    self.stubCell= [self.tabelView dequeueReusableCellWithIdentifier:@"TweetCell"];
    
    
    //self.tweets = [[NSMutableArray alloc]init];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [self.refreshControl addTarget:self action:@selector(refreshTweets) forControlEvents:UIControlEventValueChanged];
    [self.tabelView addSubview:self.refreshControl];
    
    
    [self getTimeLineTweets];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark Loading methods

- (void)refreshTweets{
    
    [self getTimeLineTweets];
    [self.refreshControl endRefreshing];
    
}

-(void) getTimeLineTweets{
    
    TwitterClient *client = [TwitterClient instance];
    if (self.feedType == TIMELINE) {
    
    [client homeTimelineWithSuccess:nil
                            success:^(NSArray *tweets) {
                                self.tweets = [[NSMutableArray alloc]initWithArray:tweets];
                                [self.tabelView reloadData];
                                NSLog(@"Success Loading tweets %lu",(unsigned long)self.tweets.count);
                                
                            } failure:^(NSError *error) {
                                NSLog(@"Falied timeline loading");
                                
                            }];
    } else if (self.feedType == MENTIONS) {
        [client mentionsTimelineWithSuccess:nil
                                success:^(NSArray *tweets) {
                                    self.tweets = [[NSMutableArray alloc]initWithArray:tweets];
                                    [self.tabelView reloadData];
                                    NSLog(@"Success Loading tweets %lu",(unsigned long)self.tweets.count);
                                    
                                } failure:^(NSError *error) {
                                    NSLog(@"Falied timeline loading");
                                    
                                }];
        
    }
    
    
}

-(void) getOlderTweetsFrom:(NSString *)lastTweetId{

    NSDictionary *param = @{@"max_id":lastTweetId };
    TwitterClient *client = [TwitterClient instance];
    [client homeTimelineWithSuccess:param success:^(NSArray *tweets) {
        [self.tweets addObjectsFromArray:tweets];
        [self.tabelView reloadData];
        NSLog(@"Success Loading tweets %lu",(unsigned long)self.tweets.count);

    } failure:^(NSError *error) {
        NSLog(@"Falied timeline loading");
        

    }];
    
   }

#pragma mark TableView methods

- (void)configureCell:(TweetCell *)tweetCell atIndexPath:(NSIndexPath *)indexPath
{
     [tweetCell initializeWithValues:self.tweets[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    [self configureCell:self.stubCell atIndexPath:indexPath];
    [self.stubCell layoutSubviews];
    
    CGSize size = [_stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height+1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell initializeWithValues:self.tweets[indexPath.row]];
    
    [cell.replyButton addTarget:self action:@selector(replyButtonClicked:) forControlEvents:UIControlEventTouchDown];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.tabelView deselectRowAtIndexPath:indexPath animated:YES];

    [self.navigationController pushViewController:detailView animated:YES];
    
    
    // Send tweet object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.tweets forKey:@"tweet"];
    [userInfo setObject:indexPath forKey:@"index"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:clickNotification
     object:self userInfo:userInfo];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tweets.count - 1 == indexPath.row){
        NSLog(@"Searching with more radius for inifinite scrolling");
        Tweet *lastTweet = self.tweets[indexPath.row];
        self.lastTweetId = lastTweet.idStr;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self getOlderTweetsFrom:self.lastTweetId];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

#pragma mark  TimeLine View buttons

-(void) replyButtonClicked:(id)sender {
    TweetCell *cell = (TweetCell *)[sender findSuperViewWithClass:[TweetCell class]];
    NSIndexPath *indexPath = [self.tabelView indexPathForCell: cell];
    Tweet *tweet = self.tweets[indexPath.row];
    
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
   
    // Send tweet object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:tweet.user.screenName forKey:@"reply"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:replyNotification
     object:self userInfo:userInfo];
   
}

- (IBAction)onNewTweetTapped:(id)sender {
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
}

- (IBAction)onHBTapped:(id)sender{
 
    UIButton *button = sender;
	switch (button.tag) {
		case 0: {
               NSLog(@"HBTapped List 0 ");
			[_delegate movePanelToOriginalPosition];
			break;
		}
			
		case 1: {
               NSLog(@"HBTapped list 1");
			[_delegate movePanelRight];
			break;
		}
			
		default:
			break;
	}
}
@end
