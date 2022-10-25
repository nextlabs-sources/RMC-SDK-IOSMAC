//
//  NXLRemoveRecipientsFromDocumentAPI.m
//  nxSDK
//
//  Created by xx-huang on 05/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLRemoveRecipientsFromDocumentAPI.h"
#import "NXLCommonUtils.h"
#import "NXLClient.h"

@implementation  NXLRemoveRecipientsFromDocumentRequest

#pragma mark -NXLRemoveRecipientsFromDocumentRequest

/**
 Request Object Format Is Just Like Follows:
 {
     "parameters": 
    {
         "userId": "1",
         "ticket": "52409E58D89C34CC94C142F9D2DA2D12",
         "duid": "D92A5F729B8437792D2221CC431E9AC1",
         "recipients": [
 
         {
         "email":"client_0002@nextlabs.com"
         },
 
         {
         "email":"client_0003@nextlabs.com"
         },
 
         {
         "email":"client_0004@nextlabs.com"
         }
         ]
     }
 }
 */

-(NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        NSData   *userId = object[USERID];
        NSString *ticket = object[TICKET];
        NSString *duid = object[DUID];
        NSArray  *recipients = object[RECIPIENTS];
        
        NSURL *apiURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/rs/share", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress]];
        
        NSDictionary *jsonDict = @{@"parameters":@{USERID:userId, TICKET:ticket, DUID:duid,RECIPIENTS:recipients}};
        NSError *error;
        
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
        
        [request setHTTPBody:bodyData];
        [request setHTTPMethod:@"DELETE"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        
        NXLRemoveRecipientsFromDocumentResponse *response = [[NXLRemoveRecipientsFromDocumentResponse alloc]init];
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

@implementation NXLRemoveRecipientsFromDocumentResponse

@end



