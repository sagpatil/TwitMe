//
//  User.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface User : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger userId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSURL *profileImageURL;
@property (nonatomic, strong) NSURL *bannerImageURL;
@property (nonatomic, assign) NSInteger tweetCount;
@property (nonatomic, assign) NSInteger followerCount;
@property (nonatomic, assign) NSInteger followingCount;

//- (instancetype)initWithDictionary:(NSDictionary*) dict;
+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
+ (void)removeCurrentUser;
@end
