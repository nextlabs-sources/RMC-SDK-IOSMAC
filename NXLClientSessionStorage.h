//
//  NXClientSessionStorage.h
//  nxrmc
//
//  Created by EShi on 8/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXLClient;
@class NXLTenant;

@interface NXLClientSessionStorage : NSObject

+ (instancetype) sharedInstance;

- (void)storeClient:(NXLClient *)client;
- (void)delClient:(NXLClient *)client;

- (NXLClient *)getClient;
@end
