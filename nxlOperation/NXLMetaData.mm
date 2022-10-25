//  NXMetaData.m
//  nxrmc
//
//  Created by Kevin on 15/5/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//


#import "NXLMetaData.h"

#import <memory>
#import <codecvt>


#import "nxlexception.hpp"

#import "GTMDefines.h"
#import "GTMBase64.h"
#import "NXLSyncHelper.h"

#import "NSData+zip.h"
#import "NSData+Encryption.h"
#import "NXLRights.h"
#import "NXLLogAPI.h"
#import "NXLSDKDef.h"
#import "NXLOpenSSL.h"
#import "NXLCacheManager.h"
#import "NXLTokenManager.h"
#import "NXLUpdateNXLMetadataAPI.h"
#import "utils.h"

#define TAGBUFLEN           4096
#define TAGSEPARATOR_TAG        @"="
#define TAGSEPARATOR_TAGS       @"\0"
#define TAGSEPARATOR_END        @"\0\0"
#define KEYDATALENGTH           (44)


@implementation NXLMetaData

+ (BOOL)isNxlFile:(NSString *)path {
    BOOL ret;
    try {
        bool b = nxl::util::simplecheck([path cStringUsingEncoding:NSUTF8StringEncoding]);
        ret = b? YES : NO;
    } catch (const nxl::exception& ex) {
        ret = NO;
    }
    
    return ret;
}

+ (BOOL)isNxlFileWithData:(NSData *)data {
    BOOL ret;
    try {
        bool b = nxl::util::simplecheck((char *)data.bytes, (int)data.length);
        ret = b? YES : NO;
    } catch (const nxl::exception& ex) {
        ret = NO;
    }
    
    return ret;
}

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile rights:(NXLRights *)rights membershipId:(NSString *)membershipId environment:(NSDictionary *)environmentDict encryptdDate:(NSDate *)encryptdDate complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock{
    // Create modified info dict to suit edit able nxl file header
      long long llDate = [encryptdDate timeIntervalSince1970] * 1000;
      NSString *modifiedBy = membershipId?:clientProfile.individualMembership.ID;
      NSString *ownerId = membershipId?:clientProfile.individualMembership.ID;
      NSNumber *createDateNum = [NSNumber numberWithLongLong:llDate];
      NSNumber *modifiedDateNum = [NSNumber numberWithLongLong:llDate];
      NSDictionary *modifiedInfoDict = @{FILE_MODIFIEDBY_KEY:modifiedBy, FILE_MODIFIEDDATE_KEY:modifiedDateNum, FILE_CREATEDDATE_KEY: createDateNum};
      
      [NXLMetaData encrypt:srcPath destPath:destPath clientProfile:clientProfile rights:rights membershipId:ownerId environment:environmentDict modifiedInfoDict:modifiedInfoDict complete:finishBlock];
}

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile rights:(NXLRights *)rights membershipId:(NSString *)membershipId environment:(NSDictionary *)environmentDict modifiedInfoDict:(NSDictionary *)modifiedInfoDict complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Step 1. Convrt file to NXL format
        ////////////////////////////////////////////////////////
        /* try to get encrytion token
         if there are still tokens in key chain, use directly
         if no tokens in key chain, try to generate tokens on server.
         */
        if ([self isNxlFile:srcPath]) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedEncrypt userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"MSG_COM_NO_PROTECT_NXL_FILE", NULL)}];
            finishBlock(error, nil, nil);
            return;
        }
        NSError* error = nil;
        NSDictionary* tokenDictionary = [[NXLTokenManager sharedInstance] getEncryptionTokenWithClientProfile:clientProfile membershipId:membershipId error:&error ];
        
        if (tokenDictionary == nil || tokenDictionary.count == 0) {
            NSLog(@"get token failed");
            
            finishBlock(error, nil, nil);
            return;
        }
        
        __block NXL_CRYPTO_TOKEN token;
        memset(&token, 0, sizeof(token));
        
        // extract public key from agreement.
        NSData* pubKeyAgreement =  tokenDictionary[TOKEN_AG_KEY];
        memcpy(token.PublicKey, [pubKeyAgreement bytes], pubKeyAgreement.length);
        NSData* iCAAgreement = tokenDictionary[TOKEN_AG_ICA];
        memcpy(token.PublicKeyWithiCA, [iCAAgreement bytes], iCAAgreement.length);
        // ml
        token.ml = [tokenDictionary[TOKEN_ML_KEY] intValue];
        // set key pair, DUID => token
        NSDictionary *tokenPairs = tokenDictionary[TOKEN_TOKENS_PAIR_KEY];
        [tokenPairs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            memcpy(token.UDID, [key cStringUsingEncoding:NSUTF8StringEncoding], 32);
            NSDictionary *valueDict = (NSDictionary *)obj;
            if (valueDict[@"otp"]) {
                memcpy(token.otp, [valueDict[@"otp"] cStringUsingEncoding:NSUTF8StringEncoding], 32);
            }
            memcpy(token.Token, [valueDict[@"token"] cStringUsingEncoding:NSUTF8StringEncoding], 64);
        }];
        
        BOOL ret = NO;
        try {
            const char* pSrc = [srcPath cStringUsingEncoding:NSUTF8StringEncoding];
            const char* pDest = [destPath cStringUsingEncoding:NSUTF8StringEncoding];
            NSString *ownerId = membershipId?:clientProfile.individualMembership.ID;
            
            // fetch file modified info
            NSString *modifedBy = modifiedInfoDict[FILE_MODIFIEDBY_KEY];
            NSNumber *modifiedDate = modifiedInfoDict[FILE_MODIFIEDDATE_KEY];
            NSNumber *createDate = modifiedInfoDict[FILE_CREATEDDATE_KEY];
            
            nxl::util::convert([ownerId cStringUsingEncoding:NSUTF8StringEncoding], [modifedBy cStringUsingEncoding:NSUTF8StringEncoding], modifiedDate.longLongValue, createDate.longLongValue, pSrc, pDest, &token, nullptr, true);
            ret = YES;
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedEncrypt userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        // STEP2. Write AD-hoc info into encrypted nxl file.
        //////////////////////////////////////////////////////////////////
        // compose policy
        NSDictionary* condition = nil;
        if (environmentDict) {
            condition = @{
                          @"subject": @{
                                  @"type": [NSNumber numberWithInt:1],
                                  @"operator": @"=",
                                  @"name": @"application.is_associated_app",
                                  @"value": [NSNumber numberWithBool:YES],
                                  },
                          @"environment":environmentDict
                          };
        }else {
            condition = @{
                          @"subject": @{
                                  @"type": [NSNumber numberWithInt:1],
                                  @"operator": @"=",
                                  @"name": @"application.is_associated_app",
                                  @"value": [NSNumber numberWithBool:YES],
                                  },
                          };
        }
        
        NSDictionary* policy = @{
                                 @"id": [NSNumber numberWithInt:0],
                                 @"name": @"Ad-hoc",
                                 @"action": [NSNumber numberWithInt:1],
                                 @"rights": [rights getNamedRights],
                                 @"conditions": condition,
                                 @"obligations": [rights getNamedObligations],
                                 };
        NSArray* policies = @[policy];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* issueDate = [NSString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
        issueDate = [issueDate substringToIndex:issueDate.length - 2];
        NSDictionary* adhoc = @{
                                @"version": @"1.0",
                                @"issuer": membershipId?:clientProfile.individualMembership.ID,
                                @"issueTime":issueDate,
                                @"policies":policies
                                };
        
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:adhoc options:0 error:nil];
        if (!data || data.length == 0) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnknown userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        try {
            nxl::util::write_section_in_nxl([destPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONPOLICY, (const char*)[data bytes], (int)data.length, 0, &token);
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        // STEP3. Update nxl meta data
        NSString *duidStr = tokenPairs.allKeys.firstObject;
        NSDictionary *tokenInfoDict = tokenPairs[duidStr];
        NSString *otpString = tokenInfoDict[@"otp"];
        NSString *filePolicy = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NXLUpdateNXLMetadataModel *updateNXLMetadataModel = [[NXLUpdateNXLMetadataModel alloc] initWithDUID:duidStr Otp:otpString protectType:@0 FilePolicy:filePolicy fileTags:@"" ml:@"0"];
        [[NXLUpdateNXLMetadataRequest alloc] requestWithObject:updateNXLMetadataModel Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
            if (error || response.rmsStatuCode != 200) {
                NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
                finishBlock(error, nil, nil);
            }else {
                finishBlock(nil, destPath, tokenPairs);
            }
        }];
    });
}

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile membershipId:(NSString *)membershipId classifications:(NSDictionary *)classificationDict encryptdDate:(NSDate *)encryptdDate complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock
{
    // Create modified info dict to suit edit able nxl file header
       long long llDate = [encryptdDate timeIntervalSince1970] * 1000;
       NSString *modifiedBy = membershipId?:clientProfile.individualMembership.ID;
       NSString *ownerId = membershipId?:clientProfile.individualMembership.ID;
       NSNumber *createDateNum = [NSNumber numberWithLongLong:llDate];
       NSNumber *modifiedDateNum = [NSNumber numberWithLongLong:llDate];
       NSDictionary *modifiedInfoDict = @{FILE_MODIFIEDBY_KEY:modifiedBy, FILE_MODIFIEDDATE_KEY:modifiedDateNum, FILE_CREATEDDATE_KEY: createDateNum};
       
       [self encrypt:srcPath destPath:destPath clientProfile:clientProfile membershipId:ownerId classifications:classificationDict modifiedInfoDict:modifiedInfoDict complete:finishBlock];
}

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile membershipId:(NSString *)membershipId classifications:(NSDictionary *)classificationDict modifiedInfoDict:(NSDictionary *)modifiedInfoDict complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Step 1. Convrt file to NXL format
        ////////////////////////////////////////////////////////
        /* try to get encrytion token
         if there are still tokens in key chain, use directly
         if no tokens in key chain, try to generate tokens on server.
         */
        NSError* error = nil;
        NSDictionary* tokenDictionary = [[NXLTokenManager sharedInstance] getEncryptionTokenWithClientProfile:clientProfile membershipId:membershipId error:&error ];
        
        if (tokenDictionary == nil || tokenDictionary.count == 0) {
            NSLog(@"get token failed");
            
            finishBlock(error, nil, nil);
            return;
        }
        
        __block NXL_CRYPTO_TOKEN token;
        memset(&token, 0, sizeof(token));
        
        // extract public key from agreement.
        NSData* pubKeyAgreement =  tokenDictionary[TOKEN_AG_KEY];
        memcpy(token.PublicKey, [pubKeyAgreement bytes], pubKeyAgreement.length);
        NSData* iCAAgreement = tokenDictionary[TOKEN_AG_ICA];
        memcpy(token.PublicKeyWithiCA, [iCAAgreement bytes], iCAAgreement.length);
        // ml
        token.ml = [tokenDictionary[TOKEN_ML_KEY] intValue];
        // set key pair, DUID => token
        NSDictionary *tokenPairs = tokenDictionary[TOKEN_TOKENS_PAIR_KEY];
        [tokenPairs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            memcpy(token.UDID, [key cStringUsingEncoding:NSUTF8StringEncoding], 32);
            NSDictionary *valueDict = (NSDictionary *)obj;
            if (valueDict[@"otp"]) {
                memcpy(token.otp, [valueDict[@"otp"] cStringUsingEncoding:NSUTF8StringEncoding], 32);
            }
            memcpy(token.Token, [valueDict[@"token"] cStringUsingEncoding:NSUTF8StringEncoding], 64);
            
        }];
        
        BOOL ret = NO;
        try {
            const char* pSrc = [srcPath cStringUsingEncoding:NSUTF8StringEncoding];
            const char* pDest = [destPath cStringUsingEncoding:NSUTF8StringEncoding];
            NSString *ownerId = membershipId?:clientProfile.individualMembership.ID;
            
            // fetch file modified info
            NSString *modifedBy = modifiedInfoDict[FILE_MODIFIEDBY_KEY];
            NSNumber *modifiedDate = modifiedInfoDict[FILE_MODIFIEDDATE_KEY];
            NSNumber *createDate = modifiedInfoDict[FILE_CREATEDDATE_KEY];
            
            nxl::util::convert([ownerId cStringUsingEncoding:NSUTF8StringEncoding], [modifedBy cStringUsingEncoding:NSUTF8StringEncoding], modifiedDate.longLongValue, createDate.longLongValue, pSrc, pDest, &token, nullptr, true);
            ret = YES;
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedEncrypt userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        // STEP2. Write classification info into encrypted nxl file.
        NSData* classificationData = [NSJSONSerialization dataWithJSONObject:classificationDict options:0 error:nil];
        if (!classificationData || classificationData.length == 0) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnknown userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        try {
            nxl::util::write_section_in_nxl([destPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONTAG, (const char*)[classificationData bytes], (int)classificationData.length, 0, &token);
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        try {
            NSData *data = [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil]; // must set .FilePolicy section for backward compatibility
            nxl::util::write_section_in_nxl([destPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONPOLICY, (const char*)[data bytes], (int)data.length, 0, &token);
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
            finishBlock(error, nil, nil);
            return;
        }
        
        // STEP3. Update nxl meta data
        NSString *duidStr = tokenPairs.allKeys.firstObject;
        NSDictionary *tokenInfoDict = tokenPairs[duidStr];
        NSString *otpString = tokenInfoDict[@"otp"];
        NSString *fileTags = [[NSString alloc] initWithData:classificationData encoding:NSUTF8StringEncoding];
        NXLUpdateNXLMetadataModel *updateNXLMetadataModel = [[NXLUpdateNXLMetadataModel alloc] initWithDUID:duidStr Otp:otpString protectType:@1 FilePolicy:@"" fileTags:fileTags ml:@"0"];
       [[NXLUpdateNXLMetadataRequest alloc] requestWithObject:updateNXLMetadataModel Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
            if (error) {
                NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
                finishBlock(error, nil, nil);
            }else {
                finishBlock(nil, destPath, tokenPairs);
            }
        }];
    });
}

+ (void)decryptNXLFileWithPolicySection:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void (^)(NSError * error, NSString* destPath, NSString *duid, NSString *ownner, NSDictionary *policySection, NSDictionary *classificationSection))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![NXLMetaData isNxlFile:srcPath]) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            finishBlock(error, nil, nil, nil, nil, nil);
            return;
        }
        
        // read ownerID
        char ownerIdbuf[256 + 1] = {0};
        int ownerIdlen = sizeof(ownerIdbuf);
        NSString *ownerId = nil;
        try {
            nxl::util::read_ownerid_from_nxl([srcPath cStringUsingEncoding:NSUTF8StringEncoding], ownerIdbuf, &ownerIdlen);
            ownerId = [NSString stringWithUTF8String:ownerIdbuf];
        } catch (const nxl::exception&ex) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedDecrypt userInfo:nil];
            finishBlock(error, nil, nil, nil, nil, nil);
            return;
        }
        
        NXL_CRYPTO_TOKEN token;
        NSError* err = nil;
        NSString *uuid = nil;
        NSDictionary *fileInfo = nil;
        NSDictionary* adhoc = nil;
        NSDictionary *classifications = nil;
        
        BOOL ret = [self getFileTokenV2:srcPath token:&token profile:clientProfile sharedInfo:sharedInfo fileInfo:&fileInfo adhocDict:&adhoc fileTagsDict:&classifications error:&err];
        char duidtemp[32 + 1] = {0};  // store duid, hex string
        memcpy(duidtemp, token.UDID, sizeof(token.UDID));
        uuid = [NSString stringWithUTF8String:duidtemp];
        if (ret == NO) {
            finishBlock(err, nil, uuid, ownerId, nil, nil);
            return;
        }
        
        try {
            const char* pSrc = [srcPath cStringUsingEncoding:NSUTF8StringEncoding];
            const char* pDest = [destPath cStringUsingEncoding:NSUTF8StringEncoding];
            nxl::util::decrypt(pSrc, pDest, &token, true);
            ret = YES;
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedDecrypt userInfo:nil];
            finishBlock(error, nil, uuid, ownerId, nil, nil);
            return;
        }
        
        if (ret == NO && adhoc == nil && classifications == nil) { // it means we can't get .FilePolicy and .FileTag sections info
            
            NSError * error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
            finishBlock(error, nil, uuid, ownerId, nil, nil);
            return;
        }
        char duid[32 + 1] = {0};  // store duid, hex string
        memcpy(duid, token.UDID, sizeof(token.UDID));
        if (adhoc.allKeys.count != 0) {
            NSArray* policies = [adhoc objectForKey:@"policies"];
            NSDictionary* policy = [policies objectAtIndex:0];
            finishBlock(nil, destPath, uuid, ownerId, policy, nil);
        }else { // not AD hoc, should be classification
            finishBlock(nil, destPath, uuid, ownerId, nil, classifications);
        }
        
    });
    
}

+ (void)decryptNXLOfflineFileWithPolicySection:(NSString *)srcPath destPath:(NSString *)destPath tokenValue:(NSString *)tokenValue duid:(NSString *)duid complete:(void (^)(NSError * error, NSString *destPath))finishBlock;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![NXLMetaData isNxlFile:srcPath]) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            finishBlock(error, nil);
            return;
        }
        
        NXL_CRYPTO_TOKEN token;
        NSError* err = nil;
        BOOL ret = [self getOfflineFileCompletedToken:&token duid:duid tokenValue:tokenValue error:&err];
        if (ret == NO) {
            finishBlock(err, nil);
            return;
        }
        
        try {
            const char* pSrc = [srcPath cStringUsingEncoding:NSUTF8StringEncoding];
            const char* pDest = [destPath cStringUsingEncoding:NSUTF8StringEncoding];
            nxl::util::decrypt(pSrc, pDest, &token, true);
            ret = YES;
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorFailedDecrypt userInfo:nil];
            finishBlock(error, nil);
            return;
        }
         finishBlock(nil, destPath);
    });
}

+ (NSDictionary *)getTags:(NSString *)path error:(NSError **)error {
    if (![NXLMetaData isNxlFile:path]) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
        }
        
        return nil;
    }
    return nil;
}

+ (BOOL)setTags:(NSDictionary *)tags forFile:(NSString *)path {
    if (![NXLMetaData isNxlFile:path]) {
        return NO;
    }
    
    return YES;
}

+ (void)getFileType:(NSString *)path clientProfile:(NXLProfile *)clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void(^)(NSString *type, NSError *error))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        if (![NXLMetaData isNxlFile:path]) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            finishBlock(nil, error);
            return;
        }
        NXL_CRYPTO_TOKEN token;
        NSDictionary *fileInfoDict = nil;
        BOOL ret = [self getFileTokenV2:path token:&token profile:clientProfile sharedInfo:sharedInfo fileInfo:&fileInfoDict adhocDict:nil fileTagsDict:nil error:&error];
        if (ret == NO) {
            finishBlock(nil, error);
            return;
        }
        
        NSString* ext = [fileInfoDict valueForKey:[NSString stringWithFormat:@"%s", FILETYPEKEY]];
        finishBlock(ext, nil);
        
    });
}


+ (void)getPolicySection:(NSString *)nxlPath clientProfile:(NXLProfile *) clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void(^)(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        if (![NXLMetaData isNxlFile:nxlPath]) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            finishBlock(nil, nil, error);
            return;
        }
        
        NSDictionary* adhoc = nil;
        NSDictionary* classification = nil;
        NXL_CRYPTO_TOKEN token;
        BOOL ret = [self getFileTokenV2:nxlPath token:&token profile:clientProfile sharedInfo:sharedInfo fileInfo:nil adhocDict:&adhoc fileTagsDict:&classification error:&error];
        if (ret == NO) {
            finishBlock(adhoc, classification, error);
            return;
        }
        finishBlock(adhoc, classification, error);
    });
}

+ (void)addAdHocSharingPolicy:(NSString *)nxlPath
                     issuer:(NSString*)issuer
                       rights:(NXLRights*)rights
                timeCondition:(NSString *)timeCondition
                clientProfile:(NXLProfile *) clientProfile
                     complete:(void(^)(NSError *error))finishBlock {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        if (![NXLMetaData isNxlFile:nxlPath]) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            finishBlock(error);
            return;
        }
        
        // compose policy
        NSDictionary* condition = @{
                                    @"subject": @{
                                                @"type": [NSNumber numberWithInt:1],
                                                @"operator": @"=",
                                                @"name": @"application.is_associated_app",
                                                @"value": [NSNumber numberWithBool:YES],
                                            },
                                    };
        NSDictionary* policy = @{
                                 @"id": [NSNumber numberWithInt:0],
                                 @"name": @"Ad-hoc",
                                 @"action": [NSNumber numberWithInt:1],
                                 @"rights": [rights getNamedRights],
                                 @"conditions": condition,
                                 @"obligations": [rights getNamedObligations],
                                 };
        NSArray* policies = @[policy];
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSString* issueDate = [NSString stringWithString:[dateFormatter stringFromDate:[NSDate date]]];
        issueDate = [issueDate substringToIndex:issueDate.length - 2];
        NSDictionary* adhoc = @{
                           @"version": @"1.0",
                           @"issuer": issuer,
                           @"issueTime":issueDate,
                           @"policies":policies
                           };
        
        
        NSData* data = [NSJSONSerialization dataWithJSONObject:adhoc options:0 error:nil];
        if (!data || data.length == 0) {
            error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnknown userInfo:nil];
            finishBlock(error);
            return;
        }
        
        
        NXL_CRYPTO_TOKEN token;
        BOOL ret = [self getFileTokenV2:nxlPath token:&token profile:clientProfile  sharedInfo:nil fileInfo:nil adhocDict:nil fileTagsDict:nil error:&error];
        if (ret == NO) {
            
            finishBlock(error);
            return;
        }
      
        
        try {
            nxl::util::write_section_in_nxl([nxlPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONPOLICY, (const char*)[data bytes], (int)data.length, 0, &token);
            finishBlock(nil);
            return;
        } catch (const nxl::exception& ex) {
            ret = NO;
        }
        if (ret == NO) {
            NSError *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableWritePolicy userInfo:nil];
            finishBlock(error);
        }
    });
}

+ (void)getOwner:(NSString *)nxlPath complete:(void(^)(NSString *ownerId, NSError *error))finishBlock {
    
    NSError *error = nil;
    if (![NXLMetaData isNxlFile:nxlPath]) {
        
        error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
        finishBlock(nil, error);
        return;
    }
    
    BOOL ret;
    char buf[256 + 1] = {0};
    int len = sizeof(buf);
    try {
        nxl::util::read_ownerid_from_nxl([nxlPath cStringUsingEncoding:NSUTF8StringEncoding], buf, &len);
        NSString *ownid = [NSString stringWithUTF8String:buf];
        finishBlock(ownid, nil);
        ret = YES;
    } catch (const nxl::exception&ex) {
        ret = NO;
    }
    if (ret == NO) {
        error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorReadOwnerFailed userInfo:nil];
        finishBlock(nil , error);
    }
}

+ (NSString *)getNXLFileDUID:(NSString *)filePath
{
    try {
        // get token related info from nxl header.
        NXL_CRYPTO_TOKEN token;
        memset(&token, 0, sizeof(token));
        
        nxl::util::read_token_info_from_nxl([filePath cStringUsingEncoding:NSUTF8StringEncoding], &token);
        
        char duid[32 + 1] = {0};  // store duid, hex string
        memcpy(duid, token.UDID, sizeof(token.UDID));
        NSString *uuid = [NSString stringWithUTF8String:duid];
        return uuid;
    } catch (const nxl::exception& ex) {
        return nil;
    }
}

+ (NSString *)getNXLFileOwnerId:(NSString *)filePath
{
    if (![NXLMetaData isNxlFile:filePath]) {
        return nil;
    }
    
    BOOL ret;
    char buf[256 + 1] = {0};
    int len = sizeof(buf);
    try {
        nxl::util::read_ownerid_from_nxl([filePath cStringUsingEncoding:NSUTF8StringEncoding], buf, &len);
        NSString *ownid = [NSString stringWithUTF8String:buf];
        return ownid;
        ret = YES;
    } catch (const nxl::exception&ex) {
        ret = NO;
    }
    return nil;
}


#pragma mark common method for this class.
+ (BOOL)getFileToken:(NSString *)nxlFile sharedInfo:(NSDictionary *)sharedInfo tokenDict:(NSDictionary **)tokenDict clientProfile:(NXLProfile *) clientProfile error:(NSError**)err
{
    BOOL ret = YES;
    NXL_CRYPTO_TOKEN token;
    *tokenDict = nil;
    if(err)
    {
         *err = nil;
    }
    ret = [self getFileTokenV2:nxlFile token:&token profile:clientProfile  sharedInfo:sharedInfo fileInfo:nil adhocDict:nil fileTagsDict:nil error:err];
    
    char duidBuffer[sizeof(token.UDID) + 1] = {0};  // store duid, hex string
    memcpy(duidBuffer, token.UDID, sizeof(token.UDID));
    NSString *udidStr = [NSString stringWithUTF8String:duidBuffer];
    
    char tokenBuffer[sizeof(token.Token) + 1] = {0};
    memcpy(tokenBuffer, token.Token, sizeof(token.Token));
    NSString *tokenStr = [NSString stringWithUTF8String:tokenBuffer];
    
    if (udidStr && tokenStr) {
        *tokenDict = @{udidStr:tokenStr};
    } else if (udidStr) {
        *tokenDict = @{udidStr: @"null value"};
    }
    return ret;
}

+ (BOOL) getNxlFile:(NSString *) nxlFile duid:(NSString **) uuid publicAgrement:(NSData **) pubAgr owner:(NSString **) owner ml:(NSString **) ml error:(NSError **) error
{
    try {
        // get token related info from nxl header.
        NXL_CRYPTO_TOKEN token;
        memset(&token, 0, sizeof(token));
        
        nxl::util::read_token_info_from_nxl([nxlFile cStringUsingEncoding:NSUTF8StringEncoding], &token);
        
        char duid[32 + 1] = {0};  // store duid, hex string
        memcpy(duid, token.UDID, sizeof(token.UDID));
        if (uuid) {
            *uuid = [NSString stringWithUTF8String:duid];
        }
        // get public key for agreement (between member and RootCA)
        if (pubAgr) {
            *pubAgr = [NSData dataWithBytes:token.PublicKey length:256];
        }
        
        if (ml) {
            *ml = [NSString stringWithFormat:@"%d", token.ml];
        }
        
    } catch (const nxl::exception& ex) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorToken userInfo:nil];
        }
        NSLog(@"read duid from nxl failed. error: %s", ex.what());
        
        return NO;
    }
    
    // get owner id from nxl header.
    [self getOwner:nxlFile complete:^(NSString *ownerId, NSError *error) {
        if (!error) {
            if (owner) {
                *owner = ownerId;
            }
        }
        
    }];
    
    if (!(*owner)) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorReadOwnerFailed userInfo:nil];
        }
        
        return NO;
    }
    return YES;
}

+ (BOOL) getFileTokenV2:(NSString *)srcPath token:(NXL_CRYPTO_TOKEN *)token profile:(NXLProfile *) userProfile sharedInfo:(NSDictionary *)sharedInfo fileInfo:(NSDictionary **)fileInfoDict adhocDict:(NSDictionary **)adhocDict fileTagsDict:(NSDictionary **)fileTagsDict error:(NSError**)err {
    //for nxl file, using uuid exiested in file to get Token.
    //for nxl file, using uuid exiested in file to get Token.
    if (![self isNxlFile:srcPath])
    {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
        }
        return NO;
    }
    NSString *uuid = nil;
    NSData *publicKeyAgreement = nil;
    NSString* ml;
    
    try {
        // get token related info from nxl header.
        NXL_CRYPTO_TOKEN token;
        memset(&token, 0, sizeof(token));
        
        nxl::util::read_token_info_from_nxl([srcPath cStringUsingEncoding:NSUTF8StringEncoding], &token);
        
        char duid[32 + 1] = {0};  // store duid, hex string
        memcpy(duid, token.UDID, sizeof(token.UDID));
        uuid = [NSString stringWithUTF8String:duid];
        
        // get public key for agreement (between member and RootCA)
        publicKeyAgreement = [NSData dataWithBytes:token.PublicKey length:256];
        ml = [NSString stringWithFormat:@"%d", token.ml];
        
    } catch (const nxl::exception& ex) {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorToken userInfo:nil];
        }
        NSLog(@"read duid from nxl failed. error: %s", ex.what());
        
        return NO;
    }
    
    if (uuid == nil) {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorToken userInfo:nil];
        }
        
        return NO;
    }
    
    memset(token, 0, sizeof(*token));
    memcpy(token->UDID, [uuid cStringUsingEncoding:NSUTF8StringEncoding], 32);
    
    // get owner id from nxl header.
    __block NSString* owner = nil;
    [self getOwner:srcPath complete:^(NSString *ownerId, NSError *error) {
        if (!error) {
            owner = ownerId;
        }
        
    }];
    
    if (!owner) {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorReadOwnerFailed userInfo:nil];
        }
        
        return NO;
    }
    
    // get file nxl info
    char buf[4096] = {0};
    int len = 4096;
    NSDictionary *fileInfo = nil;
    NSDictionary* adhoc = nil;
    NSDictionary *classifications = nil;
    NSString *policyString = nil;
    NSString *fileTags = nil;
    BOOL ret = YES;
    try {
        int flag = 0;
        // read .FileInfo section
        nxl::util::read_section_in_nxl([srcPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONINFO, buf, &len, &flag);
        NSData *fileInfoData = [NSData dataWithBytes:buf length:len];
        NSError *fileInfoError = nil;
        fileInfo = [NSJSONSerialization JSONObjectWithData:fileInfoData options:NSJSONReadingMutableContainers error:&fileInfoError];
        if (fileInfoError) {
            if (err) {
                *err = fileInfoError;
            }
            return NO;
        }
        
        
        // read .FilePolicy section
        len = 4096;
        memset(buf, 0, len);
        flag = 0;
        nxl::util::read_section_in_nxl([srcPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONPOLICY, buf, &len, &flag);
        
        NSData *data = [NSData dataWithBytes:buf length:len];
        NSError *error = nil;
        adhoc = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        policyString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error) {
            if (err) {
                *err = error;
            }
            return NO;
        }
        // read .FileTag section
        len = 4096;
        memset(buf, 0, len);
        flag = 0;
        nxl::util::read_section_in_nxl([srcPath cStringUsingEncoding:NSUTF8StringEncoding], BUILDINSECTIONTAG, buf, &len, &flag);
        NSData *fileTagData = [NSData dataWithBytes:buf length:len];
        classifications = [NSJSONSerialization JSONObjectWithData:fileTagData options:NSJSONReadingMutableContainers error:&error];
        fileTags = [[NSString alloc] initWithData:fileTagData encoding:NSUTF8StringEncoding];
        if (error) {
            if (err) {
                *err = error;
            }
            return NO;
        }
        
        
    } catch (const nxl::exception& ex) {
        ret = NO;
    }
    
    if (ret == NO && adhoc == nil && classifications == nil) { // it means we can't get .FilePolicy and .FileTag sections info
        
        NSError * error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
        if (err) {
            *err = error;
        }
        return NO;
    }
    
    char duid[32 + 1] = {0};  // store duid, hex string
    memcpy(duid, token->UDID, sizeof(token->UDID));
    NSString *tokenValue = nil;
     NSError *error = nil;
    if (adhoc.allKeys.count != 0) { // Adhoc
        tokenValue = [[NXLTokenManager sharedInstance] getAdhocFileDecryptionTokenWithDUID:[NSString stringWithUTF8String:duid] agreement:publicKeyAgreement owner:owner ml:@"0" profile:userProfile filePolicy:policyString sharedInfo:sharedInfo error:&error];
    }else { // not AD hoc, should be classification
        tokenValue = [[NXLTokenManager sharedInstance] getCentralPolicyFileDecryptionTokenWithDUID:[NSString stringWithUTF8String:duid] agreement:publicKeyAgreement owner:owner ml:@"0" profile:userProfile fileTags:fileTags sharedInfo:sharedInfo error:&error];
    }
    
    if (fileInfoDict) {
        *fileInfoDict = fileInfo;
    }
    if (adhocDict && adhoc && adhoc.allKeys.count != 0) {
        *adhocDict = adhoc;
    }
    if (fileTagsDict && classifications) {
        *fileTagsDict = classifications;
    }
    
    if (tokenValue == nil || error) {
        if (err) {
            *err = error;
        }
        return NO;
    }
    
    memset(token, 0, sizeof(*token));
    memcpy(token->UDID, [uuid cStringUsingEncoding:NSUTF8StringEncoding], 32);
    memcpy(token->Token, [tokenValue cStringUsingEncoding:NSUTF8StringEncoding], 64);
    
    return YES;
}

+ (BOOL)getOfflineFileCompletedToken:(NXL_CRYPTO_TOKEN *)token duid:(NSString *)duid tokenValue:(NSString *)tokenValue error:(NSError**)err {
    if (err == NULL) {
        return NO;
    }
    
    if (!duid || !tokenValue) {
        *err = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorToken userInfo:nil];
        return NO;
    }
  
    memset(token, 0, sizeof(*token));
    
    memcpy(token->UDID, [duid cStringUsingEncoding:NSUTF8StringEncoding], 32);
    memcpy(token->Token, [tokenValue cStringUsingEncoding:NSUTF8StringEncoding], 64);
//    (unsigned char [32]) UDID = "A2B4AF2799DE7060D21FD1875C82BA0CB20C4F573BCE62B43A5E18BAC4B4BA75A258BD08BC132FCE70B8D1D1FFC846D7"
//    Printing description of token->Token:
//    (unsigned char [64]) Token = "B20C4F573BCE62B43A5E18BAC4B4BA75A258BD08BC132FCE70B8D1D1FFC846D7"
    return YES;
}

+ (NSString *)hmacSha256Token:(NSString *) token content:(NSData *) content
{
    if (token && content) {
        char hash[64] = {0};
        int length = 64;
        nxl::util::hmac_sha256((char *)content.bytes, (int) content.length, token.UTF8String, hash, &length);
      //  nxl::hmac_sha256_token(token.UTF8String, (int)token.length, content.UTF8String, (int)content.length, hash);
        std::string sHash(hash, 64);
        return [NSString stringWithFormat:@"%s", sHash.c_str()];
    }
    
    return nil;
}

@end
