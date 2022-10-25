//
//  NXLCommonUtils.h
//  nxlMacSDK
//
//  Created by nextlabs on 14/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NXLProfile.h"
#import "NXLMetaData.h"

@interface NXLCommonUtils : NSObject

+ (NSString *) deviceID;

+ (NSNumber*) getPlatformId;

+ (NSString *) getMimeTypeByFileName:(NSString *)fileName;

+ (BOOL)isStewardUser:(NSString *)userId clientProfile:(NXLProfile *)profile;

+ (NSString *) arrayToJsonString:(NSArray *)array error:(NSError **)error;

+ (NSString *) currentRMSAddress;
+ (void) updateRMSAddress:(NSString *) rmsAddress;
@end
