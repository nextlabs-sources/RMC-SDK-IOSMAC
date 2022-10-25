//
//  NXLUpdateSharingRecipientsAPI.m
//  nxSDK
//
//  Created by EShi on 2/21/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLUpdateSharingRecipientsAPI.h"
#import "NSDictionary+Ext.h"
#import "NXLClient.h"

@implementation NXLUpdateSharingRecipientsRequest
- (NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (!self.reqRequest) {
        NSAssert([object isKindOfClass:[NSDictionary class]], @"NXLUpdateSharingRecipientsRequest should use dictionary model");
        NSArray *newRecipients = ((NSDictionary *)object)[UPDATA_RECIPIENTS_NEW_RECIPIENTS_KEY];
        NSArray *removedRecipients = ((NSDictionary *)object)[UPDATA_RECIPIENTS_REMOVE_RECIPIENTS_KEY];
        NSString *duid = ((NSDictionary *)object)[UPDATA_RECIPIENTS_DUID_KEY];
        NSString *comment = ((NSDictionary *)object)[UPDATA_RECIPIENTS_COMMENT_KEY];
        
        NSMutableArray *newRep = [NSMutableArray array];
        NSMutableArray *removeRep = [NSMutableArray array];
        
        for (NSString *email in newRecipients) {
            NSDictionary *node = @{@"email":email};
            [newRep addObject:node];
        }
        
        for (NSString *email in removedRecipients) {
            NSDictionary *node = @{@"email":email};
            [removeRep addObject:node];
        }
        
        NSDictionary *jsonDict = @{@"parameters":@{@"newRecipients":newRep, @"removedRecipients":removeRep, @"comment":comment?:@""}};
        NSData *jsonData = [jsonDict toJSONFormatData:nil];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/%@/update", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress, duid]]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:jsonData];
        self.reqRequest = request;
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLUpdateSharingRecipientsResponse *response = [[NXLUpdateSharingRecipientsResponse alloc]init];
        NSData *data = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:data];
        return  response;
    };
    return analysis;
}
@end


@implementation NXLUpdateSharingRecipientsResponse

- (void)analysisResponseData:(NSData *)responseData
{
    [super analysisResponseStatus:responseData];
}
@end
