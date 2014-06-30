//
//  ListViewController.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM  (NSInteger, FeedType){
    TIMELINE,
    MENTIONS
};


// For HamburgerView
@protocol ListViewControllerDelegate <NSObject>

@optional

- (void)movePanelRight;

@required
- (void)movePanelToOriginalPosition;

@end


@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<ListViewControllerDelegate> delegate;
@property (nonatomic, assign) FeedType feedType;

@property (strong, nonatomic) NSMutableArray* tweets;
@property (weak, nonatomic) IBOutlet UITableView *tabelView;
@property (weak, nonatomic) IBOutlet UIButton *hbButton;

@end
