//
//  NXMemshipAPI.m
//  nxrmc
//
//  Created by nextlabs on 6/24/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLMemshipAPI.h"


@implementation NXLMemshipAPIRequestModel

- (instancetype)initWithClientProfile:(NXLProfile *)clientProfile publicKey:(NSString *)publicKey memberShipId:(NSString *)memebershipId {
    if (self = [super init]) {
        _clientProfile = clientProfile;
        _publicKey = publicKey;
        _membershipId = memebershipId;
    }
    return self;
}
- (NSData *)generateBodyData {
    NSDictionary *parameters = @{@"userId": self.clientProfile.userId,
                                 @"ticket": self.clientProfile.ticket,
                                 @"membership" : self.membershipId,
                                 @"publicKey" : self.publicKey};
    
    NSDictionary *bodyData = @{@"parameters" : parameters};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyData options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"generate Membership json request data failed");
    }
    return jsonData;
}

@end

@implementation NXLMemshipAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
//    [super analysisResponseStatus:responseData];
    [self parseMembershipResponseJsonData:responseData];
}
- (void)parseMembershipResponseJsonData:(NSData *)data {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    if (error) {
        NSLog(@"parse data failed:%@", error.localizedDescription);
        return;
    }
    
    if ([result objectForKey:@"statusCode"]) {
        self.rmsStatuCode = [[result objectForKey:@"statusCode"] integerValue];
    }
    
    if ([result objectForKey:@"message"]) {
        self.rmsStatuMessage = [result objectForKey:@"message"];
    }
    
    if ([result objectForKey:@"results"]) {
        NSDictionary *certificatesResult = [result objectForKey:@"results"];
        NSString *certficatesStr = [certificatesResult objectForKey:@"certficates"];
        if (certficatesStr) {
            NSArray *array = [certficatesStr componentsSeparatedByString:@"-----BEGIN CERTIFICATE-----"];
            self.results = [[NSMutableDictionary alloc]init];
            int index = 0;
            for (int i = 0; i < array.count; i++) {
                if ([[array objectAtIndex:i] compare:@""] != NSOrderedSame) {
                    NSString *result = [NSString stringWithFormat:@"-----BEGIN CERTIFICATE-----%@", [array objectAtIndex:i]];
                    [self.results setValue:result forKey:[NSString stringWithFormat:@"certficate%d",index+1]];
                    ++index;
                }
            }
        }
    }
}

@end

@interface NXLMemshipAPI()

@property(nonatomic, strong) NXLMemshipAPIRequestModel *requestModel;

@end

@implementation NXLMemshipAPI

- (instancetype)initWithRequest:(NXLMemshipAPIRequestModel *)requestModel {
    if (self =[super init]) {
        self.requestModel = requestModel;
    }
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.requestModel.clientProfile.rmserver, @"rs/membership"]];
    [request setURL: url];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
    [request setHTTPBody:bodyData];
    
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
            NXLMemshipAPIResponse *model = [[NXLMemshipAPIResponse alloc]init];
            [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
            return  model;
    };
    return analysis;
}

@end
