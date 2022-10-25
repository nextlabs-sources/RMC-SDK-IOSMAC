//
//  NXLUtil.m
//  nxlMacSDK
//
//  Created by nextlabs on 15/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLUtil.h"

#import "NXLSDKDef.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"
#import "NXLKeyChain.h"

@implementation NXLUtil

+ (NSString *) getTempNXLFilePath:(NSString *) fileName
{
    NSString *tempFilePath = nil;
    if (fileName) {
        tempFilePath  = [self getNXLTempFolderPath];
        tempFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        tempFilePath = [tempFilePath stringByAppendingString:NXLFILEEXTENSION];
    }
    return tempFilePath;
}

+ (NSString *) getTempDecryptFilePath:(NSString *) srcPath clientProfile:(NXLProfile *) userProfile error:(NSError **) error
{
    NSString *tempFilePath = nil;
    if (srcPath) {
        tempFilePath = [self getNXLTempFolderPath];
        tempFilePath = [tempFilePath stringByAppendingPathComponent:[srcPath lastPathComponent]];
        NSError *error = nil;
        NSString *fileExt = [self getExtension:srcPath clientProfile:userProfile error:&error];
        if (error == nil) {
            tempFilePath = [tempFilePath stringByAppendingPathExtension:fileExt];
        }
    }
    return tempFilePath;
}

+ (NSString*) getNXLTempFolderPath
{
    NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:@"nxSDKTmp"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // folder is not exist,so create a new folder
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (NSString *)getExtension:(NSString *)fullpath clientProfile:(NXLProfile *) userProfile error:(NSError **)error;
{
    if (fullpath == nil) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain  code:NXLSDKErrorNoSuchFile userInfo:nil];
        }
        return  nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain  code:NXLSDKErrorNoSuchFile userInfo:nil];
        }
        return nil;
    }
    if ([NXLMetaData isNxlFile:fullpath]) {
        __block NSString *fileType = @"";
        __block NSError *tempError = nil;
        dispatch_semaphore_t semi = dispatch_semaphore_create(0);
        [NXLMetaData getFileType:fullpath clientProfile:userProfile complete:^(NSString *type, NSError *error) {
            fileType = type;
            tempError = error;
            dispatch_semaphore_signal(semi);
        }];
        dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
        if (tempError && error) {
            *error = [NSError errorWithDomain:tempError.domain code:tempError.code userInfo:tempError.userInfo];
        }
        return fileType;
    } else {
        return [[fullpath pathExtension] lowercaseString];
    }
}

+ (BOOL)isStewardUser:(NSString *)userId clientProfile:(NXLProfile *)profile {
    __block BOOL isSteward = NO;
    NSArray *memberships = profile.memberships;
    [memberships enumerateObjectsUsingBlock:^(NXLMembership *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.ID isEqualToString:userId]) {
            isSteward = YES;
        }
    }];
    return isSteward;
}




@end
