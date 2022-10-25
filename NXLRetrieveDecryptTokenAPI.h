//
//  NXLRetrieveDecryptTokenAPI.h
//  nxSDK
//
//  Created by Eren on 2019/3/18.
//  Copyright © 2019 Eren. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

NS_ASSUME_NONNULL_BEGIN
@interface NXLRetrieveDecryptTokenModel : NSObject
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *ticket;
@property(nonatomic, strong) NSString *tokenGroup;
@property(nonatomic, strong) NSString *owner;
@property(nonatomic, strong) NSString *agreement;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, assign) NSUInteger protectionType;
@property(nonatomic, strong) NSString *filePolicy;
@property(nonatomic, strong) NSString *fileTags;
@property(nonatomic, strong) NSString *ml;
@property(nonatomic, strong) NSDictionary *sharedInfo;

- (instancetype)initWithUserId:(NSString *)userId
                        ticket:(NSString *)ticket
                    tokenGroup:(NSString *)tokenGroup
                         owner:(NSString *)owner
                     agreement:(NSString *)agreement
                          duid:(NSString *)duid
               protectionType:(NSUInteger)protectionType
                    filePolicy:(nullable NSString *)filePolicy
                      fileTags:(nullable NSString *)fileTags
                            ml:(NSString *)ml
                    sharedInfo:(NSDictionary *)sharedInfo;
@end

@interface NXLRetrieveDecryptTokenRequest : NXLSuperRESTAPIRequest

@end

@interface NXLRetrieveDecryptTokenResponse : NXLSuperRESTAPIResponse
@property(nonatomic, strong) NSString *decryptToken;
@end

NS_ASSUME_NONNULL_END
