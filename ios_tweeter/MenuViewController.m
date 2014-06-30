//
//  MenuViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/29/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "MenuViewController.h"
#import "ListViewController.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MenuViewController ()
//@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) ListViewController *timelineViewController;
@property (nonatomic, strong) ListViewController *mentionsViewController;
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, assign) CGPoint viewOriginOnPan;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;

- (IBAction)onProfileClicked:(id)sender;
- (IBAction)onTimeLineTapped:(id)sender;
- (IBAction)onMentionsTapped:(id)sender;

- (IBAction)onLogoutTapped:(id)sender;

@end

@implementation MenuViewController

static float openMenuPosition = 265; //open menu x position

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.timelineViewController = [[ListViewController alloc] init];
        //    self.timelineViewController.feedType = TIMELINE;
        self.profileViewController  = [[ProfileViewController alloc] init];
        [self.profileViewController setUser:[User currentUser]];
        
        self.mentionsViewController = [[ListViewController alloc] init];
        //  self.mentionsViewController.feedType = MENTIONS;
        
//        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.timelineViewController];
//        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.184 green:0.761 blue:0.937 alpha:1.000];
//        [self.navigationController.navigationBar setTranslucent:NO];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.contentView addSubview:self.navigationController.view];
    [self.contentView addSubview:self.profileViewController.view];
 //   [self.contentView addSubview:self.timelineViewController.view];
    
    
    [self addChildViewController:self.timelineViewController];
    [_timelineViewController didMoveToParentViewController:self];
    
//    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onCustomPan:)];
//    [self.contentView addGestureRecognizer:panGestureRecognizer];
    
    [self styleMenu];
    
    //register observer for hamburger button
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleMenu) name:@"toggleMenu" object:nil];

    
}


- (void)onCustomPan:(UIPanGestureRecognizer *)panGestureRecognizer{
    CGPoint point    = [panGestureRecognizer locationInView:self.view];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.viewOriginOnPan = CGPointMake(point.x - self.contentView.frame.origin.x, point.y - self.contentView.frame.origin.y);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        float xPos = (point.x - self.viewOriginOnPan.x);
        if (xPos < 0) {
            xPos = 0;
        }
        if (xPos > openMenuPosition) {
            xPos = openMenuPosition;
        }
        self.contentView.frame = CGRectMake( xPos, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        float destinationXPos = (velocity.x > 0) ? openMenuPosition : 0;
        [UIView animateWithDuration:0.25 animations:^{
            self.contentView.frame = CGRectMake( destinationXPos, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
        }];
        [self updateMenuOptions];
    }
}

- (void)toggleMenu{
    // add tap gesture for closing menu
    if (self.tapGestureRecognizer == nil) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleMenu)];
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:self.tapGestureRecognizer];
    }
    
    float xPos = (self.contentView.frame.origin.x == 0) ? openMenuPosition : 0;
    [UIView animateWithDuration:0.4 animations:^{
        self.contentView.frame = CGRectMake( xPos, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    }];
    [self updateMenuOptions];
}


- (void)updateMenuOptions{
    BOOL isMenuOpen = self.contentView.frame.origin.x == 0;
    [self.contentView.subviews[0] setUserInteractionEnabled:isMenuOpen];
    self.tapGestureRecognizer.enabled = !isMenuOpen;
}



- (void)styleMenu{
    User *currentUser = [User currentUser];

    self.nameLabel.text = currentUser.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenName];
    [self.profileImage setImageWithURL:currentUser.profileImageURL];
    self.profileImage.layer.masksToBounds = YES;
    self.profileImage.layer.cornerRadius = 3.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onProfileClicked:(id)sender {
}

- (IBAction)onTimeLineTapped:(id)sender {
}

- (IBAction)onMentionsTapped:(id)sender {
}
- (IBAction)onLogoutTapped:(id)sender {
}
@end
