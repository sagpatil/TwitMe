//
//  HBViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/29/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "HBViewController.h"
#import "ListViewController.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MainViewController.h"
#import "LoginViewController.h"

static NSString *kHBbuttonCLicked = @"HBbuttonClick";

@interface HBViewController ()
//@property (nonatomic, strong) MainViewController *mainViewController;
//@property (nonatomic, strong) ProfileViewController *profileViewController;
//@property (nonatomic, strong) ListViewController *timelineViewController;
//@property (nonatomic, strong) UINavigationController *navigationController;


@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
- (IBAction)onHomeLine:(id)sender;
- (IBAction)onProfile:(id)sender;
- (IBAction)onMentions:(id)sender;
- (IBAction)onLogOutTap:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation HBViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleMenu];
   
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)styleMenu{
    User *currentUser = [User currentUser];
    
    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
    [self.profileImage setImageWithURL:currentUser.profileImageURL];
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.cornerRadius = 3.0f;
}




#pragma  mark Button Actions

- (IBAction)onHomeLine:(id)sender {
        NSLog(@"homeline button in Burger");

    // Send Indexenum  object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    NSNumber *index = [NSNumber numberWithInt:TimeLineVC];;
    [userInfo setObject:index forKey:@"butonClick"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kHBbuttonCLicked
     object:self userInfo:userInfo];
    
    
    //    self.window.rootViewController = nVC;
    //    nVC.navigationBar.hidden = YES;
//    UIView *timeLineView = ((UIViewController *)self.timelineViewController).view;
//    timeLineView.frame =self.contentView.frame;
//    [self.contentView addSubview:timeLineView];
}

- (IBAction)onProfile:(id)sender {
   
       NSLog(@"Profile button in Burger");
    
    // Send Indexenum  object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    NSNumber *index = [NSNumber numberWithInt:ProfileVC];;
    [userInfo setObject:index forKey:@"butonClick"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kHBbuttonCLicked
     object:self userInfo:userInfo];
    //[_delegate loadCustom];
    //[self.delegate loadVC:ProfileVC];
    
}

- (IBAction)onMentions:(id)sender {
    NSLog(@"Mentions button in Burger");
    
    // Send Indexenum  object via NSNC
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    NSNumber *index = [NSNumber numberWithInt:MentionsVC];;
    [userInfo setObject:index forKey:@"butonClick"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:kHBbuttonCLicked
     object:self userInfo:userInfo];
}

- (IBAction)onLogOutTap:(id)sender {
    [User removeCurrentUser];
    LoginViewController *lVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
    
    // [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:lVC animated:YES completion:nil];
}
@end
