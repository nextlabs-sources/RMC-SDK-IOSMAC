//
//  NXLUtil.h
//  nxlMacSDK
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    This file will be shared in both iOS and Mac, 
    so please do NOT add any platform related code here.
 */

@class NXLProfile;

@interface NXLUtil : NSObject

+ (NSString *) getTempNXLFilePath:(NSString *) fileName;

+ (NSString *) getTempDecryptFilePath:(NSString *) srcPath clientProfile:(NXLProfile *) userProfile error:(NSError **) error;

+ (BOOL)isStewardUser:(NSString *)userId clientProfile:(NXLProfile *)profile;



@end
