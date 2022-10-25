//
//  NXMetaData.h
//  nxrmc
//
//  Created by Kevin on 15/5/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLProfile.h"
#import "NXLRights.h"

// FileInfo Section key
#define FILE_TYPE_KEY                 @"fileExtension"
#define FILE_FILENAME_KEY             @"fileName"
#define FILE_MODIFIEDBY_KEY           @"modifiedBy"
#define FILE_MODIFIEDDATE_KEY         @"dateModified"
#define FILE_CREATEDBY_KEY            @"createBy"
#define FILE_CREATEDDATE_KEY          @"dateCreated"

@interface NXLMetaData : NSObject

+ (BOOL)isNxlFile:(NSString *)path;
+ (BOOL)isNxlFileWithData:(NSData *)data;
+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile rights:(NXLRights *)right membershipId:(NSString *)membershipId environment:(NSDictionary *)environmentDict encryptdDate:(NSDate *)encryptdDate complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock;
+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile membershipId:(NSString *)membershipId classifications:(NSDictionary *)classificationDict encryptdDate:(NSDate *)encryptdDate complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock;

+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile rights:(NXLRights *)right membershipId:(NSString *)membershipId environment:(NSDictionary *)environmentDict modifiedInfoDict:(NSDictionary *)modifiedInfoDict complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock;
+ (void)encrypt:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile membershipId:(NSString *)membershipId classifications:(NSDictionary *)classificationDict modifiedInfoDict:(NSDictionary *)modifiedInfoDict complete:(void(^)(NSError *error, NSString *enryptedFilePath, id appendInfo))finishBlock;

+ (void)decryptNXLFileWithPolicySection:(NSString *)srcPath destPath:(NSString *)destPath clientProfile:(NXLProfile *)clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void (^)(NSError * error, NSString* destPath, NSString *duid, NSString *ownner, NSDictionary *policySection, NSDictionary *classificationSection))finishBlock;

+ (void)decryptNXLOfflineFileWithPolicySection:(NSString *)srcPath destPath:(NSString *)destPath tokenValue:(NSString *)tokenValue duid:(NSString *)duid complete:(void (^)(NSError * error, NSString*destPath))finishBlock;

+ (void)getFileType:(NSString *)path clientProfile:(NXLProfile *)clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void(^)(NSString *type, NSError *error))finishBlock;
+ (void)getPolicySection:(NSString *)nxlPath clientProfile:(NXLProfile *) clientProfile sharedInfo:(NSDictionary *)sharedInfo complete:(void(^)(NSDictionary *policySection, NSDictionary*classificationSection, NSError *error))finishBlock;

+ (void)addAdHocSharingPolicy:(NSString *)nxlPath
                     issuer:(NSString*)issuer
                       rights:(NXLRights*)rights
                timeCondition:(NSString *)timeCondition
                clientProfile:(NXLProfile *) clientProfile
                     complete:(void(^)(NSError *error))finishBlock;

+ (void)getOwner:(NSString *)nxlPath complete:(void(^)(NSString *ownerId, NSError *error))finishBlock;

+ (NSString *)getNXLFileDUID:(NSString *)filePath;
+ (NSString *)getNXLFileOwnerId:(NSString *)filePath;

+ (NSDictionary *)getTags: (NSString *)path error:(NSError **)error;
+ (BOOL)setTags:(NSDictionary *)tags forFile:(NSString *)path;

+ (NSString *)hmacSha256Token:(NSString *) token content:(NSData *) content;

+ (BOOL)getFileToken:(NSString *)nxlFile sharedInfo:(NSDictionary *)sharedInfo tokenDict:(NSDictionary **)tokenDict clientProfile:(NXLProfile *) clientProfile error:(NSError**)err;

+ (BOOL) getNxlFile:(NSString *) nxlFile duid:(NSString **) duid publicAgrement:(NSData **) pubAgr owner:(NSString **) owner ml:(NSString **) ml error:(NSError **) error;
@end
