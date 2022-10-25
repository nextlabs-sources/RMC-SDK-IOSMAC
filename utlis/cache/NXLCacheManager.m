//
//  NXCacheManager.m
//  nxrmc
//
//  Created by Kevin on 15/5/14.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLCacheManager.h"
#import "NXLCommonUtils.h"


@implementation NXLCacheManager
+ (void) cacheRESTReq:(NXLSuperRESTAPIRequest *) restAPI cacheURL:(NSURL *) cacheURL
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:restAPI];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/\\?%*|\"<>"];
    NSString *fileName = [[restAPI.reqFlag componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    cacheURL = [cacheURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", fileName, NXLSDK_CACHE_EXTENSION]];
    [data writeToURL:cacheURL atomically:YES];
}

+ (NSURL *) getLogCacheURL:(NXLProfile *) clientProfile
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user id/rest cache/LogRest/
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:clientProfile.rmserver] URLByAppendingPathComponent:clientProfile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"LogRest"];
//
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    return cacheUrl;
}

+(NSURL *) getRESTCacheURL:(NXLProfile *) clientProfile
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user id/rest cache
    cacheUrl = [[[cacheUrl URLByAppendingPathComponent:clientProfile.rmserver] URLByAppendingPathComponent:clientProfile.userId] URLByAppendingPathComponent:@"restCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }

    return cacheUrl;
}

+ (NSURL *) getSharingRESTCacheURL:(NXLProfile *) clientProfile
{
    NSURL* cacheUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    // cache format
    // document/rms service/user id/rest cache/SharingREST/
    cacheUrl = [[[[cacheUrl URLByAppendingPathComponent:clientProfile.rmserver] URLByAppendingPathComponent:clientProfile.userId] URLByAppendingPathComponent:@"restCache"] URLByAppendingPathComponent:@"SharingREST"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheUrl.path]) {  // folder doesn't exist, create
        NSError* error = nil;
        BOOL rt = [[NSFileManager defaultManager] createDirectoryAtURL:cacheUrl withIntermediateDirectories:YES attributes:nil error:&error];
        if (!rt) {
            NSLog(@"create folder failed, %@, %@", cacheUrl, error);
            return nil;
        }
    }
    
    return cacheUrl;

}

@end
