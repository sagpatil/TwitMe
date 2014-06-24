//
//  ListViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (IBAction)onNewTweetTapped:(id)sender;
- (IBAction)onSignoutTapped:(id)sender;

@property (strong, nonatomic) NSMutableArray* tweets;
@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@end
