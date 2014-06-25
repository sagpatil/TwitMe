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
#import "LoginViewController.h"
#import "User.h"
#import "Tweet.h"
#import "MBProgressHUD.h"

static NSString *clickNotification = @"showDetail";
static NSString *replyNotification = @"replyTweet";
static NSString *newTweetNotification = @"newTweet";

@interface ListViewController ()
@property (strong, nonatomic) UIRefreshControl* refreshControl;
@property (strong, nonatomic) NSString* lastTweetId; // tweet id of last row in table. will be sent to get the older tweets for infinite scrolling

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

TweetCell * _stubCell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
        NSLog(@"Init");
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tweetNotificationReceived:)
                                                     name:newTweetNotification
                                                   object:nil];
        

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
- (void)viewDidLoad
{

    [super viewDidLoad];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.tabelView.dataSource = self;
    self.tabelView.delegate = self;
    
    UINib *customNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tabelView registerNib:customNib forCellReuseIdentifier:@"TweetCell"];
    _stubCell = [customNib instantiateWithOwner:nil options:nil][0];
    
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
    [client homeTimelineWithSuccess:nil
                            success:^(NSArray *tweets) {
                                self.tweets = [[NSMutableArray alloc]initWithArray:tweets];
                                [self.tabelView reloadData];
                                NSLog(@"Success Loading tweets %lu",(unsigned long)self.tweets.count);
                                
                            } failure:^(NSError *error) {
                                NSLog(@"Falied timeline loading");
                                
                            }];
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float additionalHeight =0;
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    CGSize boundingSize = CGSizeMake([cell tweetTextLabel].frame.size.width, FLT_MAX);
    UIFont *font = [UIFont fontWithName:@"Helvetica" size:13];
    
    CGRect textRect = [tweet.text boundingRectWithSize:boundingSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes: @{NSFontAttributeName:font} context:nil];
    [[cell tweetTextLabel] setFrame:textRect];
    
    
    if (tweet.orignalTweet) {
        additionalHeight = 15;
        NSLog(@" %@",tweet.text);
    }
    
    NSLog(@"\n for %ld Calc Height :%f  -- %f ",(long)indexPath.row, textRect.size.height,additionalHeight);
    return 60 + additionalHeight+ textRect.size.height;
}

///             TODO FIGURE OUT THE STUBCELL APPROACH AS THE CURRENT ONE ISNT FULLPROOF

//- (void)configureCell:(TweetCell *)tweetCell atIndexPath:(NSIndexPath *)indexPath
//{
//    tweetCell.tweet = self.tweets[indexPath.row];
//    
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self configureCell:_stubCell atIndexPath:indexPath];
//    [_stubCell layoutSubviews];
//    
//    CGSize size = [_stubCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    NSLog(@"--> height: %f", size.height);
//    return size.height+1;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewAutomaticDimension;
//    
//}


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
    
    NSLog(@"clicked %ld", (long)indexPath.row);
    Tweet *tweet = self.tweets[indexPath.row];
    DetailViewController *detailView = [[DetailViewController alloc] initWithNibName:@"DetailViewController" bundle:nil];
    [self.tabelView deselectRowAtIndexPath:indexPath animated:YES];
    detailView.tweetTextLabel.text = tweet.text;
    detailView.profileNameLabel.text = tweet.user.name;
    detailView.tweetHandleLabel.text = tweet.user.screenName;
    
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

- (IBAction)onSignoutTapped:(id)sender{
    [User removeCurrentUser];
    LoginViewController *lVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    
    NSLog(@"\n Presented :%@", self.presentedViewController);
    NSLog(@"\n Presenting %@", self.presentingViewController);
    
    // [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:lVC animated:YES completion:nil];
    
}
@end
