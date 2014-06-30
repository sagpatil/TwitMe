//
//  webViewController.m
//  ios_tweeter
//
//  Created by Patil, Sagar on 6/27/14.
//  Copyright (c) 2014 Patil, Sagar. All rights reserved.
//

#import "webViewController.h"
#import "ComposeViewController.h"
#import "MBProgressHUD.h"

@interface webViewController ()
@property (nonatomic,assign)int webViewLoads_;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)onBackButton:(id)sender;

- (IBAction)onComposeButton:(id)sender;
@end

@implementation webViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate=self;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:requestObj];
     [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}


//#TOdo figure out when paeg laod completes


- (void)webViewDidFinishLoad:(UIWebView *)webView{
  
    
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSLog(@"COmpleted loading");
  [MBProgressHUD hideHUDForView:self.view animated:YES];
    }

    
//    NSString *javaScript = @"function myFunction(){return 1+1;}";
//    [webView stringByEvaluatingJavaScriptFromString:javaScript];
    
//    NSLog(@"Current URL = %@",webView.);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBackButton:(id)sender {
     [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onComposeButton:(id)sender {
    ComposeViewController *newTweetVC = [[ComposeViewController alloc]initWithNibName:@"ComposeViewController" bundle:nil];
    [self presentViewController:newTweetVC animated:YES completion:nil];
}
@end
