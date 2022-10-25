//
//  NXMemshipAPI.h
//  nxrmc
//
//  Created by nextlabs on 6/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLSuperRESTAPI.h"
#import "NXLProfile.h"

@interface NXLMemshipAPIRequestModel : NSObject

@property(nonatomic, strong)NXLProfile *clientProfile;
@property(nonatomic, strong)NSString *publicKey;
@property(nonatomic, strong)NSString *membershipId;

- (instancetype)initWithClientProfile:(NXLProfile *)clientProfile publicKey:(NSString *)publicKey memberShipId:(NSString *)memebershipId;

- (NSData *)generateBodyData;

@end

@interface NXLMemshipAPIResponse : NXLSuperRESTAPIResponse

@property(nonatomic, strong) NSMutableDictionary *results;

@end

@interface NXLMemshipAPI : NXLSuperRESTAPIRequest

- (instancetype)initWithRequest:(NXLMemshipAPIRequestModel *)requestModel;

@end
