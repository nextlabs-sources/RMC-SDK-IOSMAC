//
//  NXLRetrieveDecryptTokenAPI.m
//  nxSDK
//
//  Created by Eren on 2019/3/18.
//  Copyright © 2019 Eren. All rights reserved.
//

#import "NXLRetrieveDecryptTokenAPI.h"
#import "NXLClient.h"
#import "NXLCommonUtils.h"
@implementation NXLRetrieveDecryptTokenModel
- (instancetype)initWithUserId:(NSString *)userId
                        ticket:(NSString *)ticket
                    tokenGroup:(NSString *)tokenGroup
                         owner:(NSString *)owner
                     agreement:(NSString *)agreement
                          duid:(NSString *)duid
               protectionType:(NSUInteger)protectionType
                    filePolicy:(NSString *)filePolicy
                      fileTags:(NSString *)fileTags
                            ml:(NSString *)ml
                    sharedInfo:(nonnull NSDictionary *)sharedInfo{
    if (self = [super init]) {
        _userId = userId;
        _ticket = ticket;
        _tokenGroup = tokenGroup;
        _owner = owner;
        _agreement = agreement;
        _duid = duid;
        _protectionType = protectionType;
        _filePolicy = filePolicy?:@"";
        _fileTags = fileTags?:@"";
        _ml = ml;
        _sharedInfo = sharedInfo;
    }
    return self;
}
@end

@implementation NXLRetrieveDecryptTokenRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXLRetrieveDecryptTokenModel class]], @"NXLRetrieveDecryptTokenRequest model should be NXLRetrieveDecryptTokenModel!!");
        NXLRetrieveDecryptTokenModel *model = (NXLRetrieveDecryptTokenModel *)object;
        NSMutableDictionary *dynamicEvalDic = [NSMutableDictionary dictionary];
        [dynamicEvalDic setValue:@{@"name":APPLICATION_NAME,@"path":APPLICATION_PATH,@"attributes":@{@"publisher":@[APPLICATION_PUBLISHER,@"v1"],@"licensed":@[@"yes"]}} forKey:@"application"];
        [dynamicEvalDic setValue:@{@"ipAddress":[NXLCommonUtils getCurrentIpAdress],@"attributes":@{@"hostname":@[[NXLCommonUtils getCurretnHostName]]}} forKey:@"host"];
        NSDictionary *commonParamDict = @{
                                            @"tenant" : model.tokenGroup,
                                            @"owner" : model.owner,
                                            @"agreement" : model.agreement,
                                            @"duid" : model.duid,
                                            @"protectionType" : [NSNumber numberWithUnsignedInteger:model.protectionType],
                                            @"filePolicy" : model.filePolicy,
                                            @"fileTags" : model.fileTags,
                                            @"ml" : @"0",// fixed ml 0
                                            @"dynamicEvalRequest" : dynamicEvalDic
                                    };
        
        NSData *bodyData = nil;
        if (model.sharedInfo) {
            NSMutableDictionary *sharedInfoDict = [NSMutableDictionary dictionaryWithDictionary:commonParamDict];
            [sharedInfoDict setObject:model.sharedInfo[@"sharedSpaceId"] forKey:@"sharedSpaceId"];
            [sharedInfoDict setObject:model.sharedInfo[@"sharedSpaceType"] forKey:@"sharedSpaceType"];
            [sharedInfoDict setObject:model.sharedInfo[@"sharedSpaceUserMembership"] forKey:@"sharedSpaceUserMembership"];
            NSDictionary *paramDict = @{
                @"parameters":sharedInfoDict
            };
            bodyData = [NSJSONSerialization dataWithJSONObject:paramDict options:NSJSONWritingPrettyPrinted error:nil];
        }else {
            NSDictionary *paramDict = @{
                @"parameters":commonParamDict
            };
            bodyData = [NSJSONSerialization dataWithJSONObject:paramDict options:NSJSONWritingPrettyPrinted error:nil];
        }
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/token", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:bodyData];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
        
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis anylysis = (id)^(NSString *returnData, NSError *error) {
        NXLRetrieveDecryptTokenResponse *response = [[NXLRetrieveDecryptTokenResponse alloc] init];
        NSData *backData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (backData) {
            [response analysisResponseStatus:backData];
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            if (returnDic[@"results"]) {
                NSDictionary *resultDict = returnDic[@"results"];
                response.decryptToken = resultDict[@"token"];
            }
        }
        return response;
    };
    return anylysis;
}
@end


@implementation NXLRetrieveDecryptTokenResponse



@end
