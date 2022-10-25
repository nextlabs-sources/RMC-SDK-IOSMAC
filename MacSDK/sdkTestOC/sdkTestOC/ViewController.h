//
//  ViewController.h
//  sdkTestOC
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *btnEncrypt;
@property (weak) IBOutlet NSTextField *labelHint;

@property (unsafe_unretained) IBOutlet NSTextView *textHint;
@property (weak) IBOutlet NSButton *btnDecrypt;
@property (weak) IBOutlet NSButton *btnShare;
@property (weak) IBOutlet NSButton *btnShowRights;

@end

