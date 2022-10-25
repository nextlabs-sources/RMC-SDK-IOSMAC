//
//  NXLMacClient.m
//  nxlMacSDK
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLMacClient.h"

#import "NXLMacLoginViewController.h"
#import "NXLMacSignUpViewController.h"

@implementation NXLMacClient

+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion
{
    if (completion == nil)
        return;
    
    NXLClient* client = [[NXLClient alloc]init];
    NXLMacLoginViewController* loginVC = [[NXLMacLoginViewController alloc]init];
    loginVC.completion = completion;
    
    NSViewController* contentVC = [NSApplication sharedApplication].keyWindow.windowController.contentViewController;
    
    [contentVC presentViewControllerAsModalWindow:loginVC];
    
}

+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion
                       view:(NSView *)view
{
    
    if (completion == nil)
        return;
    
    NXLClient* client = [[NXLClient alloc]init];
    NXLMacLoginViewController* loginVC = [[NXLMacLoginViewController alloc]init];
    loginVC.completion = completion;
    [view addSubview:loginVC.view];
    
}

+ (void) signUpNXLClientWithCompletion:(NXLClientSignUpCompletion)completion
{
    if (completion == nil)
        return;
    
    NXLClient* client = [[NXLClient alloc]init];
    NXLMacSignUpViewController *signUpVC = [[NXLMacSignUpViewController alloc]init];
    signUpVC.completion = completion;
    
    NSViewController* contentVC = [NSApplication sharedApplication].keyWindow.windowController.contentViewController;
    
    [contentVC presentViewControllerAsModalWindow:signUpVC];
}

@end
