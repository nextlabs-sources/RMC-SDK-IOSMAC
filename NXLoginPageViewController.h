//
//  NXLoginPageViewController.h
//  nxSDK
//
//  Created by helpdesk on 6/9/16.
//  Copyright © 2016年 Eren. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NXLClient;
typedef void(^NXLLogInCompletion)(NXLClient *client, NSError *error);

@interface NXLoginPageViewController : UIViewController

@property (nonatomic,copy)NXLLogInCompletion completion;
@end
