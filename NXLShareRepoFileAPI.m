//
//  NXLShareRepoFileAPI.m
//  nxSDK
//
//  Created by Eren (Teng) Shi on 7/11/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLShareRepoFileAPI.h"

#import "NXLClient.h"

@implementation NXLSharingRepositoryReqModel
@end

@implementation NXLShareRepoFileRequest
-(NSMutableURLRequest *) generateRequestObject:(id) object
{
    if (self.reqRequest == nil) {
        NSAssert([object isKindOfClass:[NXLSharingRepositoryReqModel class]], @"NXLSharingRepositoryRequest must be object of NXLSharingRepositoryReqModel");
        NXLSharingRepositoryReqModel *model = (NXLSharingRepositoryReqModel *)object;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rs/share/repository", [NXLClient currentNXLClient:nil].userTenant.rmsServerAddress]]];
        request.HTTPMethod = @"POST";
        
        NSDictionary *jsonDict = @{@"parameters":@{@"asAttachment":model.asAttachment?@"true":@"false",
                                                   @"sharedDocument":@{
                                                           @"membershipId":model.profile.individualMembership.ID,
                                                           @"permissions":@([model.rights getPermissions]),
                                                           /*@"tags":@{
                                                                   @"Classification":@[@"ITAR"],
                                                                   @"Clearance":@[@"Confidiential",@"Top Secret"],
                                                                   },*/
                                                           @"metadata":@"{}",
                                                           @"expireTime":@(model.expireTime.timeIntervalSince1970*1000),
                                                           @"fileName":model.file.fileName,
                                                           @"repositoryId":model.file.repoId,
                                                           @"filePathId":model.file.filePathId,
                                                           @"filePath":model.file.filePath,
                                                           @"recipients":model.recipients,
                                                           @"comment":model.comment?:@"",
                                                           },
                                                   }};
        [request setHTTPBody:[jsonDict toJSONFormatData:nil]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        self.reqRequest = request;
    }
    return self.reqRequest;
}
- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError* error){
        NXLShareRepoFileResponse *response = [[NXLShareRepoFileResponse alloc] init];
        NSData *resultData=[returnData dataUsingEncoding:NSUTF8StringEncoding];
        [response analysisResponseStatus:resultData];
        NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:nil];
        
        if ([returnDic objectForKey:@"results"]) {
            NSDictionary *result = [returnDic objectForKey:@"results"];
            [response setValuesForKeysWithDictionary:result];
        }
        
        return response;
    };
    return analysis;
}
@end

@implementation NXLShareRepoFileResponse

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"newSharedList"]) {
        self.addedharedList = value;
    }
}

@end
