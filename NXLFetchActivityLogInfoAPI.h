//
//  NXLFetchActivityLogInfoAPI.h
//  nxSDK
//
//  Created by xx-huang on 13/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLSuperRESTAPI.h"
#import "NXLFetchActivityLogInfoDataModel.h"

@interface  NXLFetchActivityLogInfoAPIRequest : NXLSuperRESTAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXLFetchActivityLogInfoAPIResponse : NXLSuperRESTAPIResponse

@property(nonatomic, strong) NSError *errorR;
@property(nonatomic, strong) NXLFetchLogInfoResultModel *model;

@end

