//
//  NXTenant.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLTenant.h"

@interface NXLTenant ()

@property(nonatomic, copy) NSString *tenantID;
@property(nonatomic, strong) NSString *rmsServerAddress;

@end
@implementation NXLTenant
#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_tenantID forKey:@"tenantID"];
    [aCoder encodeObject:_rmsServerAddress forKey:@"rmsServerAddress"];
    [aCoder encodeObject:_tenantName forKey:@"tenantName"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _tenantID = [aDecoder decodeObjectForKey:@"tenantID"];
        _rmsServerAddress = [aDecoder decodeObjectForKey:@"rmsServerAddress"];
        _tenantName = [aDecoder decodeObjectForKey:@"tenantName"];
    }
    return self;
}

@end
