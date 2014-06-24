//
//  Tweet.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/20/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"
#import "User.h"

@interface Tweet : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSString *idStr;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) NSInteger favoriteCount;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic,assign) NSUInteger *tweetId;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) Tweet *orignalTweet; // in case of retweet

@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) BOOL retweeted;
@end
