//
//  TwitterClient.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "TwitterClient.h"
#import "AFNetworking.h"
#import "User.h"
#import "Tweet.h"


#define TWITTER_BASE_URL [NSURL URLWithString:@"https://api.twitter.com"]
#define TWITTER_CONSUMER_KEY @"GCGcfvCy9rWCbKN1vk8BCrZel"
#define TWITTER_CONSUMER_SECRET @"3unsb28JSXriEwDAEgnw2xKBdhSk3AsGhsqHvFVPaR6TND7JGO"


@implementation TwitterClient
+ (TwitterClient *)instance {
    static dispatch_once_t once;
    static TwitterClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:TWITTER_BASE_URL consumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
    });
    return instance;
}


- (void)login {
    [self.requestSerializer removeAccessToken];
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"POST" callbackURL:[NSURL URLWithString:@"sptwitter://oauth"] scope:nil success:^(BDBOAuthToken *requestToken) {
        NSLog(@"Got the token");
        NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
    } failure:^(NSError *error) {NSLog(@"didn't get the token!");}];
}

- (void) logout {
    [self.requestSerializer removeAccessToken];
}

-(void) removeAccessToken {
    [self.requestSerializer removeAccessToken];
}


- (AFHTTPRequestOperation *)tweetWithSuccess:(NSDictionary *)param success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error)) failure {
    return [self POST:@"1.1/statuses/update.json" parameters:param success:success failure:failure];
}



-(AFHTTPRequestOperation *) userTimelineWithSuccess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError*error))failure {
    return [self GET:@"1.1/statuses/user_timeline.json" parameters:nil success:success failure:failure];
}

-(AFHTTPRequestOperation *) postTweetWithSuccess:(NSDictionary *)param sucess:(void(^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void(^)(AFHTTPRequestOperation *operation, NSError*error))failure{
    return [self POST:@"1.1/statuses/update.json" parameters:param success:success failure:failure];
}


//#todo unretweet (find the retweet by id and then delete it

- (void) retweet:(Tweet *)tweet success:(void (^)(Tweet* tweet))success failure:(void (^)(NSError *))failure
{
    if (tweet.retweeted) {
         failure([NSError errorWithDomain:@"Alread retweeted." code:400 userInfo:nil]);
    }
    
    NSString *retweetResource = [NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweet.idStr];
    NSNumberFormatter * tId = [[NSNumberFormatter alloc] init];
    [tId setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * tweetIDnum = [tId numberFromString:tweet.idStr];
    
    NSDictionary *params = @{@"id":tweetIDnum };
    
    [self POST:retweetResource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary*) responseObject;
                      NSLog(@"%@", response);
          
            if (success) success(tweet);
        } else {
            if (failure) failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure) failure(error);
    }];
}



- (void)homeTimelineWithSuccess:(void (^)(NSArray* tweets))success failure:(void (^)(NSError *error))failure
{
    [self GET:@"1.1/statuses/home_timeline.json"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id response){
          NSDictionary *jsonDict = response;
          NSError *error = nil;
          NSMutableArray *tweets = [[NSMutableArray alloc]init];
        
          for (int i = 0; i<jsonDict.count; i++){
              Tweet *t = [[Tweet alloc]init];
              NSDictionary *currTweet = response[i];
              t = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: currTweet error: &error];
              
              //extract the user info from the tweet
              User* currentTweetUser = [[User alloc] init];
              NSDictionary *userInfo = t.user;
              currentTweetUser = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary: userInfo error: &error];
              t.user = currentTweetUser;
              
             // in case if its a retweet process that tweet again like orignal
              if (t.orignalTweet) {
                  Tweet *ot = [[Tweet alloc]init];
                  NSDictionary *currTweet = [[NSDictionary alloc]init];
                    currTweet = t.orignalTweet;
                  ot = [MTLJSONAdapter modelOfClass: Tweet.class fromJSONDictionary: currTweet error: &error];
                  
                  //extract the user info from the tweet
                  User* currentTweetUser = [[User alloc] init];
                  NSDictionary *userInfo = ot.user;
                  currentTweetUser = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary: userInfo error: &error];
                  ot.user = currentTweetUser;
                  t.orignalTweet = ot;
                  t.text = ot.text;  // change the tweet text to oringnal tweet text
              }
              
              [tweets addObject:t];
              
          }
          success(tweets);
        }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"API Failed to get Tweets: %@", error);
          failure(error);
      }];

}

- (void)currentUserWithSuccess:(void (^)(User* currentUser))success failure:(void (^)(NSError *error))failure
{
    [self GET:@"1.1/account/verify_credentials.json"
   parameters:nil
      success:^(AFHTTPRequestOperation *operation, id response){
          NSDictionary *jsonDict = response;
          NSError *error = nil;
          //NSLog(@"%@",response);
          User* currentUser = [[User alloc] init];
          
          currentUser = [MTLJSONAdapter modelOfClass: User.class fromJSONDictionary: jsonDict error: &error];
          success(currentUser);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          NSLog(@"current user failure: %@", error);
          failure(error);
      }];
}


- (void)toggleFavoriteForTweet:(Tweet *)tweet success:(void (^)(Tweet *))success failure:(void (^)(NSError *))failure
{
    NSString* resource;
    if (!tweet.favorited) {
        resource = @"1.1/favorites/destroy.json";
//        tweet.favorited = NO;
//        tweet.favoriteCount--;
    } else {
        resource = @"1.1/favorites/create.json";
//        tweet.favorited = YES;
//        tweet.favoriteCount++;
    }
    
    NSNumberFormatter * tId = [[NSNumberFormatter alloc] init];
    [tId setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * tweetIDnum = [tId numberFromString:tweet.idStr];
    NSDictionary *params = @{@"id":tweetIDnum };
    
   
    
    [self POST:resource parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = (NSDictionary*) responseObject;
            //            NSLog(@"%@", response);
         //   Tweet *tweet = [[Tweet alloc] initWithDictionary:response];
            if (success) success(tweet);
        } else {
            if (failure) failure([NSError errorWithDomain:@"Post Tweet" code:400 userInfo:nil]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) failure(error);
    }];
}


@end
