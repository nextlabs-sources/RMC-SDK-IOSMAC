//
//  NXLogAPI.m
//  nxrmc
//
//  Created by nextlabs on 7/14/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLLogAPI.h"
#import "NSData+zip.h"
#include "NXLSDKDef.h"
#import "NXLCommonUtils.h"
#import "CHCSVParser.h"

@implementation NXLLogAPIRequestModel
-(instancetype) init
{
    self = [super init];
    if (self) {
        _duid = @"";
        _owner = @"";
        _repositoryId = @"";
        _filePathId = @"";
        _fileName = @"";
        _filePath = @"";
        _activityData = @"";
    }
    
    return self;
    
}
@end

@implementation NXLLogAPI

- (NSMutableURLRequest *)generateRequestObject:(id)object {
    
    if (self.reqRequest == nil && object && [object isKindOfClass:[NXLLogAPIRequestModel class]]) {
        NXLLogAPIRequestModel *requestModel = (NXLLogAPIRequestModel *)object;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *filePath = [paths[0] stringByAppendingPathComponent:@"tempFile.csv"];
        
        CHCSVWriter *csvWriter=[[CHCSVWriter alloc]initForWritingToCSVFile:filePath];
        [csvWriter writeField:requestModel.duid];
        [csvWriter writeField:requestModel.owner];
        [csvWriter writeField:requestModel.userID];
        [csvWriter writeField:requestModel.operation];
        [csvWriter writeField:RMC_DEVICT_ID];
        [csvWriter writeField:[NXLCommonUtils getPlatformId]];
        [csvWriter writeField:requestModel.repositoryId];
        [csvWriter writeField:requestModel.filePathId];
        [csvWriter writeField:requestModel.fileName];
        [csvWriter writeField:requestModel.filePath];
        [csvWriter writeField:APPLICATION_NAME];
        [csvWriter writeField:APPLICATION_PATH];
        [csvWriter writeField:APPLICATION_PUBLISHER];
        [csvWriter writeField:requestModel.accessResult];
        [csvWriter writeField:requestModel.accessTime];
        [csvWriter writeField:requestModel.activityData];
        [csvWriter finishLine];
        [csvWriter closeStream];
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        NSData *gzCompressedData = [data gzip];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:filePath])
        {
            if ([fileManager removeItemAtPath:filePath error:NULL]) {
                NSLog(@"remove tempfile successfully");
            }
        }
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
//        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@/%@", requestModel.rmsServer, @"rs/log/activity", requestModel.userID, requestModel.ticket]]];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", requestModel.rmsServer, @"rs/log/v2/activity"]]];
        [request setHTTPMethod:@"PUT"];
        [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Consume"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        [request setValue:@"text/csv" forHTTPHeaderField:@"Consume"];

        [request setHTTPBody:gzCompressedData];
        
        [request addValue:self.reqFlag forHTTPHeaderField:RESTAPIFLAGHEAD];
        
        self.reqRequest = request;
    }
    return (NSMutableURLRequest *)self.reqRequest;
}

- (Analysis)analysisReturnData {
    Analysis analysis = (id)^(NSString *returnData, NSError *error) {
        //restCode
        NXLLogAPIResponse *model = [[NXLLogAPIResponse alloc]init];
        [model analysisResponseStatus:[returnData dataUsingEncoding:NSUTF8StringEncoding]];
        return  model;
    };
    return analysis;
}

@end


@implementation NXLLogAPIResponse

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
