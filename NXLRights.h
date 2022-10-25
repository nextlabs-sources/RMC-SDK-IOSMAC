//
//  NXRights.h
//  nxrmc
//
//  Created by Kevin on 16/6/21.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLFileValidateDateModel.h"

typedef NS_OPTIONS(long, NXLRIGHT) {
    NXLRIGHTVIEW           = 0x00000001,
    NXLRIGHTEDIT           = 0x00000002,
    NXLRIGHTPRINT          = 0x00000004,
    NXLRIGHTCLIPBOARD      = 0x00000008,
    NXLRIGHTSAVEAS         = 0x00000010,
    NXLRIGHTDECRYPT        = 0x00000020,
    NXLRIGHTSCREENCAP      = 0x00000040,
    NXLRIGHTSEND           = 0x00000080,
    NXLRIGHTCLASSIFY       = 0x00000100,
    NXLRIGHTSHARING        = 0x00000200,
    NXLRIGHTSDOWNLOAD      = 0x00000400,
};

typedef NS_OPTIONS(long, NXLOBLIGATION){
    NXLOBLIGATIONWATERMARK = 0x40000000,
};

@interface NXLRights : NSObject<NSCopying, NSCoding>

- (id)initWithRightsObs: (NSArray*)rights obligations: (NSArray*)obs;

- (BOOL)ViewRight;
- (BOOL)ClassifyRight;
- (BOOL)EditRight;
- (BOOL)PrintRight;
- (BOOL)SharingRight;
- (BOOL)DownloadRight;
- (BOOL)DecryptRight;
- (BOOL)ScreencaptureRight;

- (BOOL)getRight:(NXLRIGHT)right;
- (void)setRight:(NXLRIGHT)right value:(BOOL)hasRight;

- (void)setRights:(long)rights;
- (void)setStringRights:(NSArray<NSString *> *)rights;
- (void)setAllRights;
- (void)setNoRights;
- (long)getRights;

- (void)setPermissions:(long)permissions;
- (long)getPermissions;
- (NSArray*)getNamedRights;

- (void)setObligation:(NXLOBLIGATION) ob value: (BOOL)hasOb;
- (BOOL)getObligation:(NXLOBLIGATION) ob;
- (NSArray*)getNamedObligations;
- (NSString *)getWatermarkString;
- (NSString *)getRightsString;
- (void)setWatermarkString:(NSString *)watermarkString;


- (void)setFileValidateDate:(NXLFileValidateDateModel *)validateDateModel;
- (NXLFileValidateDateModel *)getVaildateDateModel;

+ (NSArray *)getSupportedContentRights;
+ (NSArray *)getSupportedCollaborationRights;
+ (NSArray *)getSupportedObs;
+ (NSArray *)getSuppotedMoreOptionsRights;
@end
