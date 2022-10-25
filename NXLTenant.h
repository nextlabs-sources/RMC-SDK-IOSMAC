//
//  NXTenant.h
//  nxrmc
//
//  Created by EShi on 8/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NXLTenant : NSObject
@property(nonatomic, copy,readonly) NSString *tenantID;
@property(nonatomic, copy, readonly) NSString *tenantName;
@property(nonatomic, strong, readonly) NSString *rmsServerAddress;
@end
