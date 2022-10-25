//
//  NXLRevokingDocumentAPI.m
//  nxSDK
//
//  Created by xx-huang on 12/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLRevokingDocumentAPI.h"
#import "NXLCommonUtils.h"
#import "NXLClient.h"

@implementation NXLRevokingDocumentAPIRequest

#pragma mark -NXLRemoveRecipientsFromDocumentRequest

/**
 Request Object Format Is Just Like Follows:
 {
  "parameters":
     {
     "deviceId":"1012313431",
     "deviceType": "IPHONE",
     "duid": "D92A5F729B8437792D2221CC431E9AC1"
     }
 }
 */

-(NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {

        NSString *duid = object[@"duid"];
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/share/%@/revoke", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress,duid]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXLRevokingDocumentAPIResponse *response = [[NXLRevokingDocumentAPIResponse alloc]init];
        NSData *backData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (backData)
        {
            [response analysisResponseStatus:backData];
        }
        
        return response;
    };
    
    return analysis;
}

@end


#pragma mark -NXLRemoveRecipientsFromDocumentResponse

@implementation NXLRevokingDocumentAPIResponse

@end
