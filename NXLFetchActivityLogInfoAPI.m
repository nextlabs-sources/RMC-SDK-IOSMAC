//
//  NXLFetchActivityLogInfoAPI.m
//  nxSDK
//
//  Created by xx-huang on 13/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLFetchActivityLogInfoAPI.h"
#import "NXLCommonUtils.h"
#import "NXLClient.h"

@implementation NXLFetchActivityLogInfoAPIRequest

#pragma mark -NXLFetchActivityLogInfoAPIRequest

-(NSMutableURLRequest *)generateRequestObject:(id)object
{
    if (self.reqRequest == nil)
    {
        if (object)
        {
            NSString *duid = object[@"duid"];
            id model = object[@"parameterModel"];
            
            if([model isKindOfClass:[NXLFetchLogInfoParameterModel class]])
            {
                NXLFetchLogInfoParameterModel *paraModel = (NXLFetchLogInfoParameterModel *)model;
                
                NSString *str = [NSString stringWithFormat:@"%@/rs/log/v2/activity/%@?start=%lu&count=%lu&searchFiled=%@&searchText=%@&orderBy=%@&orderbyReverse=%@",[NXLClient currentNXLClient:nil].userTenant.rmsServerAddress,duid,(unsigned long)paraModel.start,(unsigned long)paraModel.count,paraModel.searchField,paraModel.searchText,paraModel.orderBy,paraModel.orderByReverse];
                
                NSURL *apiURL = [[NSURL alloc] initWithString:str];
                
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:apiURL];
                
                [request setHTTPMethod:@"GET"];
                
                self.reqRequest = request;
            }
        }
    }
    
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData
{
    Analysis analysis = (id)^(NSString *returnData, NSError *error){
        
        NXLFetchActivityLogInfoAPIResponse *response = [[NXLFetchActivityLogInfoAPIResponse alloc] init];
        NSData *backData = [returnData dataUsingEncoding:NSUTF8StringEncoding];
        
        if (backData){
            [response analysisResponseStatus:backData];
            
            NSDictionary *returnDic = [NSJSONSerialization JSONObjectWithData:backData options:NSJSONReadingMutableContainers error:nil];
            
            NSString *statusCode = [returnDic[@"statusCode"] stringValue];
            
            if (![statusCode isEqualToString:@"200"])
            {
                NSString *message = returnDic[@"message"];
                if (message == nil){
                    message = @"error";
                    statusCode = @"000";
                }
                
                response.errorR = [NSError errorWithDomain:message code:[statusCode integerValue] userInfo:nil];
            }
            else
            {
                NSDictionary *resultsDic = returnDic[@"results"];
                NSDictionary *dataDic = resultsDic[@"data"];
                NSArray *logrecordsArray = dataDic[@"logRecords"];
                NSMutableArray *logRecordItemsArray = [NSMutableArray array];
                
                NSString *fileName = [dataDic[@"fileName"] stringValue];
                NSUInteger totalCount = [resultsDic[@"totalCount"] integerValue];
                
                NXLFetchLogInfoResultModel *resultData = [[NXLFetchLogInfoResultModel alloc] init];
                
                for (NSMutableDictionary *modelDic in logrecordsArray){
                    NXLLogRecordItem *fileItem = [[NXLLogRecordItem alloc] initWithDictionary:modelDic];
                    
                    [logRecordItemsArray addObject:fileItem];
                }
                
                resultData.logRecordItemsArray = logRecordItemsArray;
                resultData.fileName = fileName;
                resultData.totalCount = totalCount;
                
                response.errorR = nil;
                response.model = resultData;
            }
        }
        
        return response;
    };
    
    return analysis;
}

@end

#pragma mark -NXLFetchLogInfoParameterModelResponse

@implementation NXLFetchActivityLogInfoAPIResponse

-(instancetype) init{
    self = [super init];
    if (self){
        _errorR = nil;
        _model = [[NXLFetchLogInfoResultModel alloc] init];
    }
    return self;
}
@end
