//
//  NXLUpdateSharingRecipientsAPI.h
//  nxSDK
//
//  Created by EShi on 2/21/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLSuperRESTAPI.h"

#define UPDATA_RECIPIENTS_NEW_RECIPIENTS_KEY @"UPDATA_RECIPIENTS_NEW_RECIPIENTS_KEY"
#define UPDATA_RECIPIENTS_REMOVE_RECIPIENTS_KEY @"UPDATA_RECIPIENTS_REMOVE_RECIPIENTS_KEY"
#define UPDATA_RECIPIENTS_DUID_KEY @"UPDATA_RECIPIENTS_DUID_KEY"
#define UPDATA_RECIPIENTS_COMMENT_KEY @"UPDATA_RECIPIENTS_COMMENT_KEY"
@interface NXLUpdateSharingRecipientsRequest : NXLSuperRESTAPIRequest

@end

@interface NXLUpdateSharingRecipientsResponse : NXLSuperRESTAPIResponse

@end
