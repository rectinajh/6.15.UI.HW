//
//  WebViewController.m
//  6.15.UI.HW
//
//  Created by rimi on 15/6/15.
//  Copyright (c) 2015年 rectinajh. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) UIWebView         *webView;


@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    
    NSURL *url = [NSURL URLWithString:@"http://cctv.cntv.cn/lm/tianxiazuqiu/index.shtml"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    [self.webView loadRequest:request];
    
    self.webView.scalesPageToFit = YES;
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
