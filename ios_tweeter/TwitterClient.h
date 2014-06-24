//
//  TwitterClient.h
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"
#import "Tweet.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)instance;
- (void)login ;
-(void) removeAccessToken;


-(AFHTTPRequestOperation *) userTimelineWithSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError*error))failure;

- (void) retweet:(Tweet *)tweet success:(void (^)(Tweet* tweet))success failure:(void (^)(NSError *))failure;

- (void)toggleFavoriteForTweet:(Tweet *)tweet success:(void (^)(Tweet *))success failure:(void (^)(NSError *))failure;


- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure;
- (void)homeTimelineWithSuccess:(void (^)(NSArray* tweets))success failure:(void (^)(NSError *error))failure;

-(AFHTTPRequestOperation *) postTweetWithSuccess:(NSDictionary *)param sucess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError*error))failure;
- (AFHTTPRequestOperation *)tweetWithSuccess:(NSDictionary *)param success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure;
@end
