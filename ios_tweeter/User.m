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


//#pragma Boilerplate
//
//- (instancetype)initWithDictionary:(NSDictionary*) dict;{
//    self = [super init];
//    if(self){
//        self.userId = [dict[@"id"] integerValue];
//        self.name = dict[@"name"];
//        self.screenName = dict[@"screen_name"];
//        self.tweetCount = [dict[@"statuses_count"] integerValue];
//        self.followingCount = [dict[@"friends_count"] integerValue];
//        self.followerCount = [dict[@"followers_count"] integerValue];
//
//        NSString *profileImageURLString = dict[@"profile_image_url"];
//        profileImageURLString = [profileImageURLString stringByReplacingOccurrencesOfString:@"_normal.png" withString:@"_bigger.png"];
//        self.profileImageURL = [NSURL URLWithString:profileImageURLString];
//
//        NSString *bannerURLString = dict[@"profile_banner_url"];
//        bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerURLString];
//        self.bannerImageURL = [NSURL URLWithString:bannerURLString];
//
//    }
//
//    return self;
//}
//
//#pragma mark - NSCoding
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeInteger:self.userId forKey:@"userId"];
//    [encoder encodeObject:self.name forKey:@"name"];
//    [encoder encodeObject:self.screenName forKey:@"screenName"];
//    [encoder encodeInteger:self.tweetCount forKey:@"tweetCount"];
//    [encoder encodeInteger:self.followingCount forKey:@"followingCount"];
//    [encoder encodeInteger:self.followerCount forKey:@"followerCount"];
//    [encoder encodeObject:self.profileImageURL forKey:@"profileImageURL"];
//    [encoder encodeObject:self.bannerImageURL forKey:@"bannerImageURL"];
//
//}
//
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    self = [super init];
//    if (self) {
//        self.userId = [decoder decodeIntegerForKey:@"userId"];
//        self.name = [decoder decodeObjectForKey:@"name"];
//        self.screenName = [decoder decodeObjectForKey:@"screenName"];
//        self.tweetCount = [decoder decodeIntegerForKey:@"tweetCount"];
//        self.followingCount = [decoder decodeIntegerForKey:@"followingCount"];
//        self.followerCount = [decoder decodeIntegerForKey:@"followerCount"];
//        self.profileImageURL = [decoder decodeObjectForKey:@"profileImageURL"];
//        self.bannerImageURL = [decoder decodeObjectForKey:@"bannerImageURL"];
//    }
//    return self;
//}

@end
