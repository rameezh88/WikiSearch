//
//  WikiSearchResultViewController.m
//  WikiSearch
//
//  Created by Rameez Hussain on 17/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "WikiSearchResultViewController.h"
#import "WikiSearchResult.h"
#import "UIViewController+CommonOperations.h"

@interface WikiSearchResultViewController () <UIWebViewDelegate>
@property (nonatomic, strong) IBOutlet UIWebView *webView;
@end

@implementation WikiSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.searchResult.text;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.searchResult.link]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate methods.

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [self showLoader];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [self hideLoader];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideLoader];
}

@end
