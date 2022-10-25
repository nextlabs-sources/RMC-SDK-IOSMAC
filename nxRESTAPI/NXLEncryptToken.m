//
//  NXCryptoToken.m
//  nxrmc
//
//  Created by Kevin on 16/6/16.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXLEncryptToken.h"
#import "NXLSDKDef.h"
#import "NXLClient.h"

@implementation NXLEncryptTokenAPIRequestModel

- (instancetype)initWithUserId:(NSString *)userid ticket:(NSString *)ticket membership:(NSString *)membership agreement:(NSString *)agreement {
    if (self =[self init]) {
        self.userid = userid;
        self.ticket = ticket;
        self.membership = membership;
        self.agreement = agreement;
        self.count = 100;
    }
    return self;
}

- (NSData *)generateBodyData {
    NSDictionary *parameters = @{@"userId": self.userid,
                                 @"ticket": self.ticket,
                                 @"membership" : self.membership,
                                 @"agreement" : self.agreement,
                                 @"count" : [NSNumber numberWithInteger:self.count],
                                 @"prefetch" : [NSNumber numberWithBool:YES],
                                 };
    
    NSDictionary *bodyData = @{@"parameters" : parameters};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyData options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"generate Membership json request data failed");
    }
    return jsonData;
}

@end

@implementation NXLEncryptTokenAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
//    [super analysisResponseStatus:responseData];
    [self parseEncrypTokenResponseJsonData:responseData];
}

- (void)parseEncrypTokenResponseJsonData:(NSData *)data {
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
        NSDictionary *results = [result objectForKey:@"results"];
        if ([results objectForKey:@"tokens"]) {
            self.tokens = [results objectForKey:@"tokens"];
        }
        
        if ([results objectForKey:@"ml"]) {
            self.ml = [results objectForKey:@"ml"];
        }
    }
    
    
}

@end

@interface NXLEncryptTokenAPI()

@property(nonatomic, strong) NXLEncryptTokenAPIRequestModel *requestModel;

@end

@implementation NXLEncryptTokenAPI

- (instancetype)initWithRequest:(NXLEncryptTokenAPIRequestModel *)requestModel {
    if (self = [super init]) {
        self.requestModel = requestModel;
    }
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    NSData *bodyData = [self.requestModel generateBodyData];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress, @"rs/token"]]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
    [request setHTTPBody:bodyData];
    
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLEncryptTokenAPIResponse *model = [[NXLEncryptTokenAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end
