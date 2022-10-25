//
//  NXLRevokingDocumentAPI.h
//  nxSDK
//
//  Created by xx-huang on 12/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

#define DUID           @"duid"

@interface  NXLRevokingDocumentAPIRequest : NXLSuperRESTAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXLRevokingDocumentAPIResponse : NXLSuperRESTAPIResponse

@end

