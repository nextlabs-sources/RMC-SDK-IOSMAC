//
//  NXSharingAPI.h
//  nxrmc
//
//  Created by EShi on 7/4/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLSuperRESTAPI.h"


#define DEVICE_TYPE_KEY     @"deviceType"
#define METADATA_KEY        @"metadata"
#define FILENAME_KEY        @"fileName"
#define DUID_KEY            @"duid"
#define TIKECT_KEY          @"ticket"
#define USER_ID_KEY         @"userId"
#define DEVICE_ID_KEY       @"deviceId"
#define RECIPIENTS_KEY_D      @"recipients"
#define PERMISSIONS_KEY     @"permissions"
#define SHARED_DOC_KEY      @"sharedDocument"
#define MEMBER_SHIP_ID_KEY  @"membershipId"
#define CHECK_SUM_KEY       @"checksum"

@interface NXLSharingAPIRequest : NXLSuperRESTAPIRequest

-(NSMutableURLRequest *) generateRequestObject:(id) object;
- (Analysis)analysisReturnData;
@end


@interface NXLSharingAPIResponse : NXLSuperRESTAPIResponse
@end
