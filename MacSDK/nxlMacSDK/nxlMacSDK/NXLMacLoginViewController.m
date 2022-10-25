  //
//  NXMacLoginViewController.m
//  nxlMacSDK
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLMacLoginViewController.h"

#import <WebKit/WebKit.h>

#import "NXLRouterLoginPageURL.h"
#import "NXLMacClient.h"
#import "NXLProfile.h"
#import "NXLClientSessionStorage.h"
#import "NXLCommonUtils.h"

#define WIDTH 420
#define HEIGHT 600

#define kObserveName        @"observe"

@interface NXLMacLoginViewController  ()  <WKScriptMessageHandler,WKNavigationDelegate,WKUIDelegate>

@property (strong, nonatomic) NSProgressIndicator *activityIndicatorView;

@property (strong, nonatomic) NSString *rmsAddress;

@property (strong, nonatomic) WKWebView *wkWebView;

@end

@implementation NXLMacLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self.view setWantsLayer:true];
    [self.view.layer setBackgroundColor:[NSColor whiteColor].CGColor];
    [self startAuthentication];
}

- (void) viewWillAppear
{
    [super viewWillAppear];
    
    self.view.window.title = @"Login";
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
    [self.wkWebView removeFromSuperview];
    self.wkWebView = nil;
    
    //step2.
    [self cleanWebViewCache];
    
    //step3.
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
//    config.selectionGranularity = WKSelectionGranularityCharacter;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    [config.userContentController addScriptMessageHandler:self name:kObserveName];
    
    
    NSString *source = @"var s_ajaxListener = new Object();s_ajaxListener.tempOpen = XMLHttpRequest.prototype.open;XMLHttpRequest.prototype.open = function() {this.addEventListener('readystatechange', function() {var result = eval(\"(\" + this.responseText + \")\");alert('2');if(result.statusCode == 200 && result.message == \"Authorized\") {var temp = this.responseText;window.webkit.messageHandlers.observe.postMessage(temp);}}, false);s_ajaxListener.tempOpen.apply(this, arguments);}";
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController removeAllUserScripts];
    [config.userContentController addUserScript:userScript];
    
    NSString *cookieJS = [[NSString alloc] initWithFormat:@"document.cookie ='clientId=%@';document.cookie = 'platformId=%@';", [NXLCommonUtils deviceID], [NXLCommonUtils getPlatformId].stringValue];
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:cookieJS  injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [config.userContentController addUserScript:cookieScript];
    WKWebView *wkView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    [self.view addSubview:wkView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:wkView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:wkView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:wkView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:wkView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    self.wkWebView = wkView;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    
    [self.view addSubview:self.activityIndicatorView positioned:NSWindowAbove relativeTo:nil];
    [self showActivityView];
    
    __weak typeof(self) weakSelf = self;
    NXLRouterLoginPageURL * router = [[NXLRouterLoginPageURL alloc]initWithRequest:DEFAULT_TENANT_ID];
    [router requestWithObject:nil Completion:^(id response, NSError *error) {
        NSLog(@"getLoginURL response: %@", response);
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
           //     [NXLCommonUtils showAlertViewInViewController:self title:ALERTVIEW_TITLE message:error.localizedDescription];
           //     [weakSelf hiddenActivityView];
                weakSelf.completion(nil, error);
            });
            
            return;
            
        } else {
            assert(response);
            NXLRouterLoginPageURLResponse *pageURLResonse = (NXLRouterLoginPageURLResponse *)response;
            if (pageURLResonse.rmsStatuCode != 200) {
                dispatch_async(dispatch_get_main_queue(), ^{
           //         [NXLCommonUtils showAlertViewInViewController:self title:ALERTVIEW_TITLE message:pageURLResonse.rmsStatuMessage];
           //         [weakSelf hiddenActivityView];
                    weakSelf.completion(nil, error);
                });
                
                return;
            } else {
                // show login page successfully
                weakSelf.rmsAddress = pageURLResonse.loginPageURLstr;
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/tenant?tenant=%@", weakSelf.rmsAddress, DEFAULT_TENANT_ID]]];
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

- (void)parseLoginResult:(NSString*)result {
    
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    NXLClient * client = [[NXLMacClient alloc]init];
    
    NSDictionary *userInfo = [ret objectForKey:@"extra"];
    
    NSString *tenantId = [userInfo objectForKey:@"tenantId"];
    
    NXLProfile *profile = [[NXLProfile alloc] init];
    
    
    NSMutableArray *memberships = [[NSMutableArray alloc]init];
    [[userInfo objectForKey:@"memberships"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NXLMembership *membership = [[NXLMembership alloc] init];
        membership.ID = [obj objectForKey:@"id"];
        membership.type = [obj objectForKey:@"type"];
        membership.tenantId = [obj objectForKey:@"tenantId"];
        if ([membership.tenantId isEqualToString:tenantId]) {
            profile.defaultMembership = membership;
        }
        [memberships addObject:membership];
    }];
    
    
    profile.memberships = memberships;
    
    NSNumber *userid = [userInfo objectForKey:@"userId"];
    profile.userId = [NSString stringWithFormat:@"%ld", userid.longValue];
    
    profile.userName = [userInfo objectForKey:@"name"];
    profile.ticket = [userInfo objectForKey:@"ticket"];
    profile.ttl = [userInfo objectForKey:@"ttl"];
    profile.email = [userInfo objectForKey:@"email"];
    profile.rmserver = self.rmsAddress;
    profile.idpType = [userInfo objectForKey:@"idpType"];
    [client setValue:profile forKey:@"profile"];
    NXLTenant * currentTenant =[[NXLTenant alloc] init];
    [currentTenant setValue:[profile.rmserver copy] forKey:@"rmsServerAddress"];
    [currentTenant setValue:DEFAULT_TENANT_ID forKey:@"tenantID"];
    [client setValue:currentTenant forKey:@"userTenant"];
    [client setValue:profile.userId forKey:@"userID"];
    [[NXLClientSessionStorage sharedInstance] storeClient:client];
    
    [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:kObserveName];
    
    [self hiddenActivityView];
    // destroy current vc
    [self dismissController:nil];
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewController:self];
    }
    else {
        [self.view removeFromSuperview];
        [self dismissController:nil];
    }
    
    self.completion(client, nil);
}

#pragma -mark Property
- (NSProgressIndicator *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[NSProgressIndicator alloc] initWithFrame:CGRectMake((self.view.bounds.size.width/2.0)-15.0, (self.view.bounds.size.height/2.0)-15.0, 30, 30)];
        _activityIndicatorView.style = NSProgressIndicatorSpinningStyle;
        [_activityIndicatorView setWantsLayer:true];
        [_activityIndicatorView.layer setBackgroundColor:[NSColor whiteColor].CGColor];
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
    [self showActivityView];
    [self parseLoginResult:message.body];
}

@end
