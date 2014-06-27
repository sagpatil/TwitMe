//
//  User.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/19/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

static NSString * const CurrentUserKey = @"com.sagar.twitter.current_user";
@implementation User

static  User* _currentUser = nil;

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"userId": @"id",
             @"name": @"name",
             @"screenName": @"screen_name",
             @"tweetCount": @"statuses_count",
             @"followingCount": @"friends_count",
             @"followerCount": @"followers_count",
             @"profileImageURL": @"profile_image_url",
             @"bannerImageURL": @"profile_banner_url"
             };
}

+ (NSValueTransformer *)profileImageURLJSONTransformer{
    
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)bannerImageURLJSONTransformer{
    
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}



#pragma mark - Class Methods

+ (User *)currentUser{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(!_currentUser){
        NSData *data = [defaults dataForKey:CurrentUserKey];
        if (data) {
            User *currentUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            _currentUser = currentUser;
        }
    }
    return _currentUser;
}


+ (void) setCurrentUser: (User *)user{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(!_currentUser){
        _currentUser = user;
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:user];
        [defaults setObject:data forKey:CurrentUserKey];
        [defaults synchronize];
        
    }else{ // remove current user
        [self removeCurrentUser];
    }
    
    [defaults synchronize];
}

+ (void)removeCurrentUser{
    _currentUser = nil;
    [[TwitterClient instance]removeAccessToken];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CurrentUserKey];
    [defaults synchronize];
   

}

@end
