//
//  NXUpdateNXLMetadataAPI.m
//  nxrmc
//
//  Created by Eren on 2019/3/15.
//  Copyright © 2019 nextlabs. All rights reserved.
//

#import "NXLUpdateNXLMetadataAPI.h"
#import "NXLClient.h"
@implementation NXLUpdateNXLMetadataModel
- (instancetype)initWithDUID:(NSString *)duid Otp:(NSString *)otp protectType:(NSNumber *)protectType FilePolicy:(NSString *)filePolicy fileTags:(NSString *)fileTags ml:(NSString *)ml {
    if (self = [super init]) {
        _duid = [duid copy];
        _protectType = protectType;
        _otp = otp?:@"";
        _filePolicy = filePolicy?:@"";
        _fileTags = fileTags?:@"";
        _ml = ml?:@"0";
    }
    return self;
}


@end

@implementation NXLUpdateNXLMetadataRequest : NXLSuperRESTAPIRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object {
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXLUpdateNXLMetadataModel class]], @"NXLUpdateNXLMetadataRequest model must be NXLUpdateNXLMetadataModel!");
        NXLUpdateNXLMetadataModel *model = (NXLUpdateNXLMetadataModel *)object;
        NSDictionary *paramDict = @{@"parameters":@{
                                            @"otp":model.otp,
                                            @"protectionType":model.protectType,
                                            @"filePolicy":model.filePolicy,
                                            @"fileTags":model.fileTags,
                                            @"ml":model.ml,
                                            }
                                    };
        NSData *paramData = [paramDict toJSONFormatData:nil];
        NSString *urlStr = [NSString stringWithFormat:@"%@/rs/token/%@", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress, model.duid];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"PUT"];
        [request setHTTPBody:paramData];
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        NXLUpdateNXLMetadataResponse *response =[[NXLUpdateNXLMetadataResponse alloc]init];
        NSData *resultData =[returnData dataUsingEncoding:NSUTF8StringEncoding];
        if (returnData) {
            [response analysisResponseStatus:resultData];
        }
        return response;
    };
    return analysis;
}
@end

@implementation NXLUpdateNXLMetadataResponse


@end
