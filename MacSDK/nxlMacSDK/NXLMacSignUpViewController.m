//
//  NXLMacSignUpViewController.m
//  nxlMacSDK
//
//  Created by xx-huang on 22/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXLMacSignUpViewController.h"
#import <WebKit/WebKit.h>
#import "NXLRouterLoginPageURL.h"
#import "NXLMacClient.h"
#import "NXLProfile.h"
#import "NXLClientSessionStorage.h"
#import "NXLCommonUtils.h"

#define WIDTH 420
#define HEIGHT 600

#define kObserveName        @"observe"

@interface NXLMacSignUpViewController ()<WKScriptMessageHandler,WKNavigationDelegate>

@property (strong, nonatomic) NSString *rmsAddress;
@property (strong, nonatomic) WKWebView *wkWebView;

@property (strong, nonatomic) NSProgressIndicator *activityIndicatorView;

@end

@implementation NXLMacSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self startAuthentication];
}

- (void) viewWillAppear
{
    [super viewWillAppear];
    
    self.view.window.title = @"Sign up";
}

- (void) viewDidAppear
{
    [super viewDidAppear];
    
    self.view.window.styleMask = NSWindowStyleMaskClosable | NSWindowStyleMaskTitled;
}

- (void)loadView
{
    NSView *view = [[NSView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    
    self.view = view;
}

- (void)startAuthentication {
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    
    self.wkWebView.UIDelegate = nil;
    self.wkWebView.navigationDelegate = nil;
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    
    //step2.
    [self cleanWebViewCache];
    
    //step3.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    [config.userContentController addScriptMessageHandler:self name:kObserveName];
    
    NSString *source = @"var s_ajaxListener = new Object();s_ajaxListener.tempOpen = XMLHttpRequest.prototype.open;XMLHttpRequest.prototype.open = function() {this.addEventListener('readystatechange', function() {var result = eval(\"(\" + this.responseText + \")\");alert('2');if(result.statusCode == 200 && result.message == \"Authorized\") {var temp = this.responseText;window.webkit.messageHandlers.observe.postMessage(temp);}}, false);s_ajaxListener.tempOpen.apply(this, arguments);}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController removeAllUserScripts];
    [config.userContentController addUserScript:userScript];
    WKWebView *wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:wkView];
    self.wkWebView = wkView;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    [self.wkWebView addSubview:self.activityIndicatorView];
    [self showActivityView];
    
    __weak typeof(self) weakSelf = self;
    NXLRouterLoginPageURL * router = [[NXLRouterLoginPageURL alloc]initWithRequest:DEFAULT_TENANT_ID];
    [router requestWithObject:nil Completion:^(id response, NSError *error) {
        NSLog(@"getLoginURL response: %@", response);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.completion(nil, error);
            });
            
            return;
            
        } else {
            assert(response);
            NXLRouterLoginPageURLResponse *pageURLResonse = (NXLRouterLoginPageURLResponse *)response;
            if (pageURLResonse.rmsStatuCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.completion(nil, error);
                });
                
                return;
            } else {
                weakSelf.rmsAddress = pageURLResonse.loginPageURLstr;
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/Register.jsp?tenant=%@", weakSelf.rmsAddress, DEFAULT_TENANT_ID]]];
                NSString *headV = [[NSString alloc] initWithFormat:@"clientId=%@;platformId=%@", [NXLCommonUtils deviceID], [NXLCommonUtils getPlatformId].stringValue];
                [request addValue:headV forHTTPHeaderField:@"Cookie"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.wkWebView loadRequest:request];
                });
                
            }
        }
    }];
}

- (void)cleanWebViewCache {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
}

#pragma -mark Property
- (NSProgressIndicator *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[NSProgressIndicator alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/2.0)-15.0, (self.view.bounds.size.height/2.0)-15.0, 30, 30)];
        _activityIndicatorView.style = NSProgressIndicatorSpinningStyle;
    }
    return _activityIndicatorView;
}

#pragma -mark WKNavigationDelegate

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;
{
    [self hiddenActivityView];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self hiddenActivityView];
}

#pragma -mark WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    [[NSWorkspace sharedWorkspace] openURL:navigationAction.request.URL];
    return nil;
}

#pragma -mark Private Method
- (void)showActivityView
{
    [self.activityIndicatorView setHidden:NO];
    [self.activityIndicatorView setIndeterminate:YES];
    [self.activityIndicatorView startAnimation:self];
}

- (void)hiddenActivityView {
    [self.activityIndicatorView stopAnimation:self];
    [self.activityIndicatorView setHidden:YES];
}

#pragma -mark WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.wkWebView loadHTMLString:@"" baseURL:nil];
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    
    self.completion(nil, nil);
}

@end
