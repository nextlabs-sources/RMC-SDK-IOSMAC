//
//  NXLRouterLoginPageURL.m
//  nxSDK
//
//  Created by helpdesk on 9/9/16.
//  Copyright © 2016年 Eren. All rights reserved.
//

#import "NXLRouterLoginPageURL.h"


#import "NXLCommonUtils.h"
#import "NXLSDKDef.h"


@interface NXLRouterLoginPageURL ()
{
    NSString* tenantName;
}

@end

@implementation NXLRouterLoginPageURL

-(instancetype) initWithRequest:(NSString *)tenant
{
    if (self = [super init]) {
        tenantName = tenant;
    }
    
    return self;
}

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *userEnteredServerUrl = object;
    NSString *url;
    if (tenantName) {
        url= [NSString stringWithFormat:@"%@/%@/%@",userEnteredServerUrl
              , @"router/rs/q/tokenGroupName", tenantName];
    }else{
        url= [NSString stringWithFormat:@"%@/%@",userEnteredServerUrl
              , @"router/rs/q/defaultTenant"];
    }
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    
    [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
    
    return request;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLRouterLoginPageURLResponse *response = [[NXLRouterLoginPageURLResponse alloc] init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  response;
    };
    return analysis;
}

@end


@implementation NXLRouterLoginPageURLResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseRouterLoginResponseJsonData:responseData];
}

- (void)parseRouterLoginResponseJsonData:(NSData *)responseData {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
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
        if ([results objectForKey:@"server"]) {
            self.loginPageURLstr = [results objectForKey:@"server"];
            [NXLCommonUtils updateRMSAddress:self.loginPageURLstr];
        }
    }
}

@end

