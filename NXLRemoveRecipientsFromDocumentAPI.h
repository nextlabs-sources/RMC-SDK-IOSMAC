//
//  NXLRemoveRecipientsFromDocumentAPI.h
//  nxSDK
//
//  Created by xx-huang on 05/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

#define USERID      @"userId"
#define TICKET      @"ticket"
#define DUID        @"duid"
#define RECIPIENTS  @"recipients"

@interface  NXLRemoveRecipientsFromDocumentRequest : NXLSuperRESTAPIRequest

-(NSURLRequest *)generateRequestObject:(id)object;
- (Analysis)analysisReturnData;

@end

@interface NXLRemoveRecipientsFromDocumentResponse : NXLSuperRESTAPIResponse

@end

