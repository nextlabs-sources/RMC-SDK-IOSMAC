//
//  NXLCheckValidTokenAPI.m
//  nxlMacSDK
//
//  Created by xx-huang on 24/02/2017.
//  Copyright © 2017 nextlabs. All rights reserved.
//

#import "NXLCheckValidTokenAPI.h"

@implementation NXLCheckValidTokenAPIRequest

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (self.reqRequest == nil && object && [object isKindOfClass:[NXLCheckValidTokenAPIRequest class]]){
        NSString *token = object[@"token"];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"rs/log/v2/activity/?token=%@",token]]];
        [request setHTTPMethod:@"GET"];
        [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
        
        self.reqRequest = request;
    }
    return self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLCheckValidTokenAPIResponse *response = [[NXLCheckValidTokenAPIResponse alloc]init];
        [response analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  response;
    };
    return analysis;
}

@end

@implementation NXLCheckValidTokenAPIResponse

- (void)analysisResponseStatus:(NSData *)responseData {
    [self parseLogResponseJsonData: responseData];
}

- (void)parseLogResponseJsonData:(NSData *)data {
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
}
@end
