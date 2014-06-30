//
//  MainViewController.m
//  ios_tweeter
//   http://www.raywenderlich.com/32054/how-to-create-a-slide-out-navigation-like-facebook-and-path
//  Created by Patil, Sagar on 6/29/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "MainViewController.h"
#import "HBViewController.h"
#import "ListViewController.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import <QuartzCore/QuartzCore.h>

static NSString *kHBbuttonCLicked = @"HBbuttonClick";

#define CENTER_TAG 1
#define LEFT_PANEL_TAG 2
#define CORNER_RADIUS 4
#define SLIDE_TIMING .25
#define PANEL_WIDTH 60

@interface MainViewController () 
@property (nonatomic, strong) ProfileViewController *profileViewController;
@property (nonatomic, strong) ListViewController *timelineViewController;
@property (nonatomic, strong) ListViewController *mentionsViewController;
@property (nonatomic, strong) HBViewController *hbViewController;
@property (nonatomic, strong) UINavigationController *navigationController;



@property (nonatomic, assign) BOOL showingLeftPanel;

@property (nonatomic, assign) BOOL showPanel;  // for pan gesture
@property (nonatomic, assign) CGPoint preVelocity;
@end

@implementation MainViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Main ViewDid Load");
    self.profileViewController = [[ProfileViewController alloc]init];
     self.profileViewController.user = [User currentUser];
    self.profileViewController.hbButton.tag = 0;
    self.profileViewController.delegate = self;
    self.profileViewController.view.tag =CENTER_TAG;
    
    
    self.timelineViewController = [[ListViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.timelineViewController];
    self.timelineViewController.feedType = TIMELINE;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.view.tag =CENTER_TAG;
    self.navigationController.delegate =self;
    self.timelineViewController.delegate =self;
    
    self.mentionsViewController = [[ListViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mentionsViewController];
    self.mentionsViewController.feedType = MENTIONS;
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.view.tag =CENTER_TAG;
    self.navigationController.delegate =self;
    self.mentionsViewController.delegate =self;
    
    [self loadVC:MentionsVC];
    
    [self setupGestures];

}

- (void) loadCustom{
    
    NSLog(@"from HBVC");
}



- (void) loadVC:(int)vc{
    NSLog(@"In Load VC %d", vc);
    switch (vc) {
        case TimeLineVC:
            self.currentViewController = self.navigationController;
            break;
        case ProfileVC:
            self.currentViewController = self.profileViewController;
            break;
        case MentionsVC:
              self.timelineViewController.feedType = MENTIONS;            
            self.currentViewController = self.navigationController;
            break;
            
        default:
            break;
    }
 
    UIView *currentView = ((UIViewController *)self.timelineViewController).view;
    self.currentViewController.view.frame = currentView.frame;

    
    [self.view addSubview:self.currentViewController.view];
    [self addChildViewController:self.currentViewController];
    [self movePanelToOriginalPosition];
}

#pragma mark - setup

- (void)setupGestures
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    
    [self.currentViewController.view addGestureRecognizer:panRecognizer];
}

-(void)movePanel:(id)sender
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer*)sender;
    
    NSLog(@"Panning detetcted");
    [[[pan view] layer] removeAllAnimations];
    
    CGPoint translatedPoint = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    
    if ([pan state] ==  UIGestureRecognizerStateBegan) {
        UIView *childView = nil;
        
        if(velocity.x > 0)
        {
            if (!self.showingLeftPanel) {
                childView = [self getLeftView];
            }
        }
        // // Make sure the view you're working with is front and center.
        // send HBview back and show timeLIne view
        [self.view sendSubviewToBack:childView];
        [[sender view] bringSubviewToFront:[pan view]];
    
    }

    
    if([pan state] == UIGestureRecognizerStateEnded) {
        
        if(velocity.x > 0) {
             NSLog(@"gesture went right + ended");
        } else {
             NSLog(@"gesture went left + ended");
        }
        
        if (!_showPanel) {
            [self movePanelToOriginalPosition];
        } else {
            if (_showingLeftPanel) {
                [self movePanelRight];
            }
        }
    }
    if([pan state] == UIGestureRecognizerStateChanged) {
        if(velocity.x > 0) {
             NSLog(@"gesture went right + chnages");
        } else {
             NSLog(@"gesture went left + chnages");
        }
        
        // Are you more than halfway? If so, show the panel when done dragging by setting this value to YES (1).
        self.showPanel = abs([sender view].center.x - self.currentViewController.view.frame.size.width/2) > self.currentViewController.view.frame.size.width/2;
        NSLog(@" show Panel panel %d",self.showPanel);
        
        // Allow dragging only in x-coordinates by only updating the x-coordinate with translation position.
        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [pan setTranslation:CGPointMake(0,0) inView:self.view];
        
        // If you needed to check for a change in direction, you could use this code to do so.
        if(velocity.x*_preVelocity.x + velocity.y*_preVelocity.y > 0) {
             NSLog(@"same direction");
        } else {
             NSLog(@"opposite direction");
        }
        
        _preVelocity = velocity;
    }

}

#pragma mark : View stuff

- (void)showCenterViewWithShadow:(BOOL)value withOffset:(double)offset
{
    if (value)
    {
        [self.currentViewController.view.layer setCornerRadius:CORNER_RADIUS]; // somehow this diesnt set the corber radius
        [self.currentViewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
        [self.currentViewController.view.layer setShadowOpacity:0.8];
        [self.currentViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
        
    }
    else
    {
        [self.currentViewController.view.layer setCornerRadius:0.0f];
        [self.currentViewController.view.layer setShadowOffset:CGSizeMake(offset, offset)];
    }
}

-(UIView *)getLeftView {
	// init view if it doesn't already exist
	if (self.hbViewController == nil)
	{
		// this is where you define the view for the left panel
		self.hbViewController = [[HBViewController alloc] initWithNibName:@"HBViewController" bundle:nil];
		self.hbViewController.view.tag = LEFT_PANEL_TAG;
		self.hbViewController.delegate = self.currentViewController;
        
		[self.view addSubview:self.hbViewController.view];
        
		[self addChildViewController:self.hbViewController];
		[self.hbViewController didMoveToParentViewController:self];
        
		self.hbViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	}
    
	self.showingLeftPanel = YES;
    
	// setup view shadows
	[self showCenterViewWithShadow:YES withOffset:-2];
    
	UIView *view = self.hbViewController.view;
	return view;
}


#pragma mark Delegate Actions

- (void)movePanelRight // to show left panel
{
    
       NSLog(@"right deegate ");
    
    UIView *childView = [self getLeftView];
    [self.view sendSubviewToBack:childView];
    
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.currentViewController.view.frame = CGRectMake(self.view.frame.size.width - PANEL_WIDTH, 0, self.view.frame.size.width, self.view.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                            // setButton tags for all VC
                             self.timelineViewController.hbButton.tag = 0;
                             self.profileViewController.hbButton.tag = 0;
                         }
                     }];
}



- (void)movePanelToOriginalPosition
{
       NSLog(@"delegate Orignal");
    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                              animations:^{
        self.currentViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        [self resetMainView];
    }];
}

- (void) resetMainView{
    if (self.hbViewController) {
        [self.view sendSubviewToBack:self.hbViewController.view];
        // setButton tags for all VC
        self.timelineViewController.hbButton.tag = 1;
        self.profileViewController.hbButton.tag = 1;
        self.showingLeftPanel = NO;
    }
    // remove shadows
    [self showCenterViewWithShadow:NO withOffset:0];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVC:) name:kHBbuttonCLicked object:nil];
    }
    return self;
}

- (void) showVC:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:kHBbuttonCLicked]){
        NSDictionary* userInfo = notification.userInfo;
        
        NSNumber *index = [userInfo objectForKey:@"butonClick"];
        
         NSLog (@"Notification is successfully received! %d",index.intValue);
        [self loadVC:index.intValue];
    }
}
@end
