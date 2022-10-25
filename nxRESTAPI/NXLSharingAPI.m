//
//  NXSharingAPI.m
//  nxrmc
//
//  Created by EShi on 7/4/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLSharingAPI.h"
#import "NXLSDKDef.h"
#import "NXLClient.h"



#pragma mark - -------------NXSharingAPIRequest-------------
@implementation NXLSharingAPIRequest

-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (object && [object isKindOfClass:[NSDictionary class]]) {
        
        NSDictionary *parameters =(NSDictionary *) object;
        
        NSDictionary *jsonDict = @{@"parameters" : parameters};
        NSError *error;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        
                NSString* urlStr= [NSString stringWithFormat:@"%@/%@", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress, @"rs/share"];

        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"consume"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:bodyData];
        
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;  // return self.reqRequest for if we decode from cached file, the self.reqRequest is from cache file, not above codes
}
- (Analysis)analysisReturnData
{
    Analysis ret = (id)^(NSString *returnData, NSError *error)
    {
         NXLSharingAPIResponse *response = [[NXLSharingAPIResponse alloc] init];
        if (returnData) {
            NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
           
            [response analysisResponseStatus:data];
        }
        return response;
    };
    
    return ret;
}
@end

#pragma mark - -------------NXSharingAPIResponse-------------
@implementation NXLSharingAPIResponse
@end
