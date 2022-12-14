//
//  NXSyncHelper.h
//  nxrmc
//
//  Created by EShi on 7/8/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLSuperRESTAPI.h"

typedef void(^UploadFailedRESTRequestComplection)(id object, NSError *error);

@interface NXLSyncHelper : NSObject
@property(nonatomic, readonly, strong) dispatch_queue_t uploadPerviousFailedRESTQueue;

+(instancetype) sharedInstance;
-(void) cacheRESTAPI:(NXLSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL;
-(void) uploadPreviousFailedRESTRequestWithCachedURL:(NSURL *) cachedURL mustAllSuccess:(BOOL) mustAllSuccess Complection:(UploadFailedRESTRequestComplection) complectionBlock;
@end
