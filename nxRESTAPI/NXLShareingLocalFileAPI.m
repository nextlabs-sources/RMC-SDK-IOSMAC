//
//  NXLShareingLocalFileAPI.m
//  nxSDK
//
//  Created by EShi on 12/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLShareingLocalFileAPI.h"
#import "NSDictionary+Ext.h"
#import "NXLProfile.h"
#import "NXLCommonUtils.h"
#import "NXLMultipartFormDataMaker.h"

#pragma mark - ------------------------------ NXLShareingLocalFileRequest ------------------------------
@implementation NXLShareingLocalFileRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
        NSDictionary *modelDict = (NSDictionary *)object;
        NXLProfile *profile = (NXLProfile *)modelDict[USER_PROFILE_KEY];
        NSArray *recipient = modelDict[RECIPIENTS_KEY];
        NSDate *expiredDate = modelDict[EXPIRE_TIME_KEY];
        NXLRights *rights = modelDict[RIGHTS_KEY];
        NSData *contentData = object[CONTENT_DATA_KEY];
        NSString *fileName = object[FILE_NAME_KEY];
        NSNumber * shareAsAttachment = object[SHARE_AS_ATTACHMENT];
        NSString *comment = object[COMMENT_KEY];
        
        NSString *filePath = object[FILEPATH_KEY];
        NSString *filePathId = object[FILEPATHID_KEY];
        NSDictionary *validateDateDict = object[VALIDATE_KEY];
        NSString *watermark = object[WATERMARK_KEY];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/local", profile.rmserver]]];
        [request setHTTPMethod:@"POST"];
        
        NSString *stringBoundary =@"----WebKitFormBoundary7MA4YWxkTrZu0gW";
        [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
 
        NSMutableDictionary *sharedDocumentInfoDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                        @"membershipId":profile.individualMembership.ID,
                                                                                                        @"permissions":@(rights.getPermissions),
                                                                                                        /*@"tags":@{
                                                                                                         @"Classification":@[@"ITAR"],
                                                                                                         @"Clearance":@[@"Confidiential",@"Top Secret"],
                                                                                                         },*/
                                                                                                        @"metadata":@"{}",
                                                                                                        @"expireTime":@(expiredDate.timeIntervalSince1970*1000),
                                                                                                        @"recipients":recipient,
                                                                                                        @"comment":comment?:@"",
                                                                                                        @"filePath": filePath?:@"",
                                                                                                        @"filePathId": filePathId?:@"",
                                                                                                        @"userConfirmedFileOverwrite":@"true",
                                                                                                        @"expiry":validateDateDict,
                                                                                                        @"userConfirmedFileOverwrite":@"true",
                                                                                                        }];
        if (watermark.length > 0 && [rights getObligation:NXLOBLIGATIONWATERMARK]) {
            [sharedDocumentInfoDict setObject:watermark forKey:@"watermark"];
        }
        
        NSDictionary *jsonDict = @{@"parameters":@{@"asAttachment":shareAsAttachment.boolValue?@"true":@"false",
                                                   @"sharedDocument":sharedDocumentInfoDict,
                                                   }};
        
        NSString *jsonString = [jsonDict toJSONFormatString:nil];
        
        NXLMultipartFormDataMaker *formdataMaker = [[NXLMultipartFormDataMaker alloc] initWithBoundary:stringBoundary];
        [formdataMaker addTextParameter:@"API-input" parameterValue:jsonString];
        [formdataMaker addFileParameter:@"file" fileName:fileName fileData:contentData];
        [formdataMaker endFormData];
        NSData *formData = [formdataMaker getFormData];
        [request setHTTPBody:formData];
        self.reqRequest = request;
        
    }
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        NXLShareingLocalFileResponse *response = [[NXLShareingLocalFileResponse alloc] init];
        [response analysisResponseData:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return response;
    };
    return analysis;
}
@end



#pragma mark - ------------------------------ NXLShareingLocalFileResponse ------------------------------
@implementation NXLShareingLocalFileResponse
- (void)analysisResponseData:(NSData *)responseData
{
    if (responseData) {
        [self analysisResponseStatus:responseData];
        NSError *error = nil;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
        if (!error) {
            self.serviceTime = result[@"serverTime"];
            NSDictionary *duidResult = result[@"results"];
            self.duid = duidResult[@"duid"];
            self.pathId = duidResult[@"filePathId"];
            self.fileName = duidResult[@"fileName"];
            self.alreadySharedList = duidResult[@"alreadySharedList"];
            self.anewSharedList = duidResult[@"newSharedList"];
            
          
        }
        
    }
}



@end
