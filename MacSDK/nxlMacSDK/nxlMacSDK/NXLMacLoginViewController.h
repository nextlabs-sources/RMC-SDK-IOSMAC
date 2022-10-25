//
//  NXMacLoginViewController.h
//  nxlMacSDK
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NXLClient.h"

@interface NXLMacLoginViewController : NSViewController

@property (nonatomic,copy)NXLClientLogInCompletion completion;

@end
