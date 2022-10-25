//
//  ViewController.m
//  sdkTestOC
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "ViewController.h"

#import "../../nxlMacSDK/nxlMacSDK/NXLClient.h"
#import "../../../NXLTenant.h"

@interface ViewController ()

@property(strong) NXLClient* curClient;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    _btnEncrypt.enabled = false;
    _btnDecrypt.enabled = false;
    _btnShare.enabled = false;
    _btnShowRights.enabled = false;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)loginClicked:(id)sender {
    [self showText:@"---------------Try to call NXLClient logInNXLClientWithCompletion\r\n"];
    
    [NXLClient logInNXLClientWithCompletion:^(NXLClient *client, NSError *error) {
        NSLog(@"login callback, %@", client);
        
        [self showText:[NSString stringWithFormat:@"    result, NXLClient: %@\r\n", client]];
        
        if (error == nil)
        {
            [self showText:[NSString stringWithFormat:@"    TenantID in NXLClient: %@\r\n\r\n", client.userTenant.tenantID]];
            
            [_labelHint setStringValue:client.userTenant.tenantID];
            _curClient = client;
            _btnEncrypt.enabled = true;
            _btnDecrypt.enabled = true;
            _btnShare.enabled = true;
            _btnShowRights.enabled = true;
        }
    }];
}

- (void) showText: (NSString*) str
{
    NSAttributedString* attr = [[NSAttributedString alloc] initWithString:str];
    
    [[_textHint textStorage] appendAttributedString:attr];
    [_textHint scrollRangeToVisible:NSMakeRange([[_textHint string] length], 0)];
}

- (IBAction)recoverFromKeyChain:(id)sender {
    [self showText:@"---------------Try to call NXLClient currentNXLClient\r\n"];
    
    NXLClient* client = [NXLClient currentNXLClient:nil];
    
    [self showText:[NSString stringWithFormat:@"    result, NXLClient: %@\r\n", client]];
    
    if (client != nil)
    {
        [self showText:[NSString stringWithFormat:@"    TenantID in NXLClient: %@\r\n\r\n", client.userTenant.tenantID]];
        
        [_labelHint setStringValue:client.userTenant.tenantID];
        _curClient = client;
        _btnEncrypt.enabled = true;
        _btnDecrypt.enabled = true;
        _btnShare.enabled = true;
        _btnShowRights.enabled = true;
    }
}
- (IBAction)encryptClicked:(id)sender {
    
    NXLRights* rights= [[NXLRights alloc] init];
    [rights setRight:NXLRIGHTVIEW value:YES];
    
    
    NSURL* src = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test.rtf"];
    NSURL* dest = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test.rtf.nxl"];
    
    [self showText:[NSString stringWithFormat:@"---------------Try to call NXLClient encryptToNXLFile\r\n        source: %@\r\n        dest: %@\r\n", src.absoluteString, dest.absoluteString]];
    
    [_curClient encryptToNXLFile: src destPath: dest overwrite:YES permissions:rights withCompletion:^(NSURL *filePath, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showText:[NSString stringWithFormat:@"    result, target file path: %@, error: %@\r\n\r\n", filePath, error]];
        });
        
        
        
        NSLog(@"encrypt result: %@", filePath);
    }];
}
- (IBAction)decryptClicked:(id)sender {
    NSURL* dest = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test-decrypted.rtf"];
    NSURL* src = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test.rtf.nxl"];
    
    [self showText:[NSString stringWithFormat:@"---------------Try to call NXLClient decryptNXLFile\r\n        source: %@\r\n        dest: %@\r\n", src.absoluteString, dest.absoluteString]];
    [_curClient decryptNXLFile:src destPath:dest overwrite:YES withCompletion:^(NSURL *filePath, NXLRights *rights, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showText:[NSString stringWithFormat:@"    result, target file path: %@, error: %@\r\n\r\n", filePath, error]];
        });
    }];
    
}
- (IBAction)shareClicked:(id)sender {
    NSURL* src = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test.rtf"];
    NSURL* dest = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test-share.rtf.nxl"];
    
    NXLRights* rights= [[NXLRights alloc] init];
    [rights setRight:NXLRIGHTVIEW value:YES];
    [rights setRight:NXLRIGHTPRINT value:YES];
    
    [self showText:[NSString stringWithFormat:@"---------------Try to call NXLClient shareFile\r\n        source: %@\r\n        dest: %@\r\n", src.absoluteString, dest.absoluteString]];
    NSArray* recipients = @[@"nextlabs@126.com"];
    [_curClient shareFile:src destPath:dest overwrite:YES recipients:recipients permissions:rights expiredDate:nil withCompletion:^(NSURL *filePath, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showText:[NSString stringWithFormat:@"    result, target file path: %@, error: %@\r\n\r\n", filePath, error]];
        });
    }];
}
- (IBAction)showRightsClicked:(id)sender {
    NSURL* src = [NSURL URLWithString:@"/Users/nextlabs/Documents/tmp/test-share.rtf.nxl"];
    
    [self showText:[NSString stringWithFormat:@"---------------Try to call NXLClient getNXLFileRights\r\n        source: %@\r\n", src.absoluteString]];
    
    [_curClient getNXLFileRights:src withCompletion:^(NXLRights *rights, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error != nil)
            {
                [self showText:[NSString stringWithFormat: @"failed: %@\r\n", error]];
            }
            else{
                [self showText:[NSString stringWithFormat:@"    result, error: %@, all rights:\r\n%@\r\n\r\n", error, rights]];
            }
            
        });
    }];
}

@end
