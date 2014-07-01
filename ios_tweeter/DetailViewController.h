//
//  DetailViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/20/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface DetailViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Tweet *tweet;
@property (strong, nonatomic) NSMutableArray* tweets;



- (IBAction)onBackClicked:(id)sender;
- (IBAction)onReplyClicked:(id)sender;
- (IBAction)onReplySmallClicked:(id)sender;
- (IBAction)onRetweetButtonClicked:(id)sender;
- (IBAction)onfavoriteButtonClicked:(id)sender;

@end
