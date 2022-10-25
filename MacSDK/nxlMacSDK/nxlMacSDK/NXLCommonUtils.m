//
//  NXLCommonUtils.m
//  nxlMacSDK
//
//  Created by nextlabs on 14/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLCommonUtils.h"

#import "NXLKeyChain.h"
#import "NXLSDKDef.h"

@implementation NXLCommonUtils

+ (NSString *) deviceID
{
    NSString *deviceID = (NSString *)[NXLKeyChain load:NXL_KEYCHAIN_DEVICE_ID];
    if (deviceID == nil) {
        deviceID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [NXLKeyChain save:NXL_KEYCHAIN_DEVICE_ID data:deviceID];
    }
    
    return deviceID;
}

+ (NSNumber*) getPlatformId
{
    NSProcessInfo *pInfo = [NSProcessInfo processInfo];
 //   NSString *version = [pInfo operatingSystemVersionString];
    NSOperatingSystemVersion ver = [pInfo operatingSystemVersion];
    
    int platformId = 300;
    if (ver.majorVersion == 10 && ver.minorVersion <= 99 && ver.minorVersion >= 1)
    {
        platformId += ver.minorVersion;
    }
    return [NSNumber numberWithInt:platformId];
}

+ (NSString *) getMimeTypeByFileName:(NSString *)fileName
{
    if (fileName == nil) {
        return nil;
    }
    
    NSString *fileExtension = [fileName componentsSeparatedByString:@"."].lastObject;
    if (fileExtension == nil) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeTypeStr = (__bridge_transfer NSString *)mimeType;
    if (mimeTypeStr == nil) {
        if([fileExtension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return @"text/x-java-source";
        }
        NSString *extentensionText = @"cpp, c, h";
        NSRange foundOjb = [extentensionText rangeOfString:fileExtension options:NSCaseInsensitiveSearch];
        if (foundOjb.length > 0) {
            return @"text/plain";
        }
        return @"application/octet-stream";
    }
    return mimeTypeStr;
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

+ (NSString *) arrayToJsonString:(NSArray *)array error:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:error];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *) currentRMSAddress
{
    NSString *RMSAddress = [[NSUserDefaults standardUserDefaults] objectForKey:NXRMS_ADDRESS_KEY];
    return (RMSAddress?RMSAddress:@"");
    
}

+ (void) updateRMSAddress:(NSString *) rmsAddress
{
    if (rmsAddress && ![rmsAddress isEqualToString:@""] && ![rmsAddress isEqualToString:[self currentRMSAddress]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:rmsAddress forKey:NXRMS_ADDRESS_KEY];
    }
}

@end
