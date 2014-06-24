//
//  Tweet.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/20/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "Tweet.h"
#import "Mantle.h"
#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@implementation Tweet


+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{
            // @"tweetId": @"id",
             @"idStr": @"id_str",  
             @"retweetCount": @"retweet_count",
             @"favoriteCount": @"favorite_count",
             @"text": @"text",
             @"createdAt":@"created_at",
             @"orignalTweet":@"retweeted_status"  // assign the whole retweet json to tweet object .- getTiimeLine will figure it out
             };
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        NSDate *date = [[self dateFormatter] dateFromString:str];
        return date;
    } reverseBlock:^(NSDate *date) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSDateFormatter *)dateFormatter
{
    static NSDateFormatter *_formatter;
    
    if (!_formatter) {
        _formatter = [NSDateFormatter new];
        _formatter.dateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy";
    }
    return _formatter;
}


@end
