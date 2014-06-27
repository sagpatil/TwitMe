//
//  ProfileBannerView.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/26/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import <AFNetworking/UIImageView+AFNetworking.h>
#import "ProfileBannerView.h"

@interface ProfileBannerView ()
@property (strong, nonatomic) IBOutlet ProfileBannerView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImageView;

@end

@implementation ProfileBannerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//
//+ (id)profileBannerView{
//    ProfileBannerView *customView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileBannerView" owner:nil options:nil] lastObject];
//    
//    // make sure customView is not nil or the wrong class!
//    if ([customView isKindOfClass:[ProfileBannerView class]])
//        return customView;
//    else
//        return nil;
//}

-(void)didMoveToWindow{
    NSLog(@"Loading elemensts in custom View");
    self.nameLabel.text = self.user.name;
    self.handleLabel.text = _user.screenName;
    [self.profileImageView setImageWithURL:self.user.profileImageURL];
    [self.bannerImageView setImageWithURL:self.user.bannerImageURL];
    [self.bannerImageView.superview sendSubviewToBack:self.bannerImageView];
}


-(void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"ProfileBannerView" owner:self options:nil];
    [self addSubview: self.contentView];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // rawing code
 }
 */

@end
