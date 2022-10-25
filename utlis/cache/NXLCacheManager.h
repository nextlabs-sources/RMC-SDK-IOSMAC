//
//  NXCacheManager.h
//  nxrmc
//
//  Created by Kevin on 15/5/14.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXLSDKDef.h"
#import "NXLSuperRESTAPI.h"
#import "NXLProfile.h"

@interface NXLCacheManager : NSObject


+ (void) cacheRESTReq:(NXLSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL;

+ (NSURL *) getRESTCacheURL:(NXLProfile *) clientProfile;
+ (NSURL *) getSharingRESTCacheURL:(NXLProfile *) clientProfile;
+ (NSURL *) getLogCacheURL:(NXLProfile *) clientProfile;



@end
