//
//  NXUpdateNXLMetadataAPI.h
//  nxrmc
//
//  Created by Eren on 2019/3/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
@interface NXLUpdateNXLMetadataModel : NSObject
- (instancetype)initWithDUID:(NSString *)duid Otp:(NSString *)otp protectType:(NSNumber *)protectType FilePolicy:(NSString *)filePolicy fileTags:(NSString *)fileTags ml:(NSString *)ml;

@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *otp;
@property(nonatomic, strong) NSNumber *protectType;
@property(nonatomic, strong) NSString *filePolicy;
@property(nonatomic, strong) NSString *fileTags;
@property(nonatomic, strong) NSString *ml;
@end

@interface NXLUpdateNXLMetadataRequest : NXLSuperRESTAPIRequest

@end

@interface NXLUpdateNXLMetadataResponse : NXLSuperRESTAPIResponse

@end

NS_ASSUME_NONNULL_END
