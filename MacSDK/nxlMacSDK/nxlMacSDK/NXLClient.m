//
//  NXLClient.m
//  nxlMacSDK
//
//  Created by nextlabs on 14/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLClient.h"
#import "NXLMacClient.h"

#import "NXLClientSessionStorage.h"
#import "NXLSDKDef.h"

#import "NXLUtil.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"
#import "NXLSharingAPI.h"
#import "NXLCommonUtils.h"
#import "NXLLogAPI.h"
#import "NXLCheckValidTokenAPI.h"
#import "NXLUpdateSharingRecipientsAPI.h"
#import "NXLShareingLocalFileAPI.h"
#import "NXLRemoveRecipientsFromDocumentAPI.h"
#import "NXLRevokingDocumentAPI.h"
#import "NXLTokenManager.h"

#import "NXLShareRepoFileAPI.h"

@interface NXLClient ()

//@property(nonatomic, strong) NXLProfile *profile;

@property(nonatomic, strong) NSMutableDictionary *compBlockDict;

@end

@implementation NXLClient 

- (NSMutableDictionary *) compBlockDict
{
    if (_compBlockDict == nil) {
        _compBlockDict = [[NSMutableDictionary alloc] init];
    }
    return _compBlockDict;
}

- (NXLClientIdpType)idpType
{
    return self.profile.idpType.longLongValue;
}

+ (NXLClient *)currentNXLClient:(NSError **)error
{
    NXLClient *client = [[NXLClientSessionStorage sharedInstance] getClient];
    if (client) {
        if ([client isSessionTimeout]) {
            if (error) {
                *error = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorUserSessionTimeout userInfo:nil];
            }
            [[NXLClientSessionStorage sharedInstance] delClient:client];
            client = nil;
        }
    }
    return client;
}

+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion
{
    // need to use preprocessor micro to call different sub class functions TBD
    [NXLMacClient logInNXLClientWithCompletion:completion];
}

+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion view:(NSView *)view
{
    [NXLMacClient logInNXLClientWithCompletion:completion view:view];
}

+ (void) signUpNXLClientWithCompletion:(NXLClientSignUpCompletion)completion
{
    [NXLMacClient signUpNXLClientWithCompletion:completion];
}

+ (void)checkValidToken:(NSString *)token WithCompletion:(NXLCheckValidTokenCompletion)completion;
{
    NSDictionary *tokenDic =@{@"token":token};
    NXLCheckValidTokenAPIRequest *checkTokenReq = [[NXLCheckValidTokenAPIRequest alloc] init];
    
    if ([checkTokenReq isKindOfClass:[NXLCheckValidTokenAPIRequest class]]) {
        
        [checkTokenReq requestWithObject:tokenDic Completion:^(id response, NSError *error) {
            if (!error) {
                completion(@"success",nil);
            }
            else
            {
                 completion(@"failed",error);
            }
        }];
    }
}

- (void) encryptToNXLFile:(NSURL *)filePath
                 destPath:(NSURL *)destPath
                overwrite:(BOOL)isOverwrite
              permissions:(NXLRights *)permissions
           withCompletion:(encryptToNXLFileCompletion)completion
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath.path])
    {
        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
        completion(nil, error);
        return;
    }
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, destPathError);
        return;
    }
    BOOL isCustomDestPath = destPath? YES: NO;
    
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    // default have view right
    if (permissions == nil) {
        permissions = [[NXLRights alloc] init];
    }
    [permissions setRight:NXLRIGHTVIEW value:YES]; // default have view rights
    
    NSString *fileName = [filePath pathComponents].lastObject;
    NSString *encryptDestPath = nil;
    if (destPath) {
        encryptDestPath = [destPath.path copy];
    }else
    {
        encryptDestPath = [NXLUtil getTempNXLFilePath:fileName];
    }
    
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
//    [NXLMetaData encrypt:filePath.path destPath:encryptDestPath clientProfile:self.profile complete:^(NSError *error, id appendInfo) {
//
//        __strong typeof(weakSelf) strongSelf = weakSelf;
//        if (error) {
//            if (strongSelf.compBlockDict[operationIdentify]) {
//                ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, error);
//                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
//            }
//        }else if(strongSelf.compBlockDict[operationIdentify]){  // add rights
//            [NXLMetaData addAdHocSharingPolicy:encryptDestPath issuer:strongSelf.profile.defaultMembership.ID rights:permissions timeCondition:nil clientProfile:strongSelf.profile complete:^(NSError *error) {
//                if (error) {
//                    if (strongSelf.compBlockDict[operationIdentify]) {
//                        ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, error);
//                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
//                    }
//                }else
//                {
//                    if (strongSelf.compBlockDict[operationIdentify]) {
//                        ((encryptToNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))([NSURL fileURLWithPath:encryptDestPath isDirectory:NO], nil);
//                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
//                    }
//                }
//
//                NSError *fileMgrError = nil;
//                if (!isCustomDestPath) {
//                    [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
//                }
//            }];
//        }else
//        {
//            NSError *fileMgrError = nil;
//            if (!isCustomDestPath) {
//                [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
//            }
//        }
//    }];
}

- (void) decryptNXLFile:(NSURL *)filePath destPath:(NSURL *)destPath overwrite:(BOOL)isOverwrite withCompletion:(decryptNXLFileCompletion) completion
{
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, nil, destPathError);
        return;
    }
    BOOL isCustomDestPath = destPath? YES: NO;
    NSError *error = nil;
    NSString *decryptPath = nil;
    if (destPath) {
        decryptPath = [destPath.path copy];
    }else
    {
        decryptPath = [NXLUtil getTempDecryptFilePath:filePath.path clientProfile:self.profile error:&error];
    }
    
    if (decryptPath == nil) {
        completion(nil, nil, error);
        return;
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    [NXLMetaData decrypt:filePath.path destPath:decryptPath clientProfile:self.profile complete:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, nil, error);
            return;
        }
        
        if (strongSelf.compBlockDict[operationIdentify]) {
            [strongSelf getNXLFileRights:filePath withCompletion:^(NXLRights *rights, BOOL isOwner, NSError *error) {
                //                if(strongSelf.decryptCompletion)
                if (error) {
                    ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, nil, error);
                    
                }else
                {
                    ((decryptNXLFileCompletion)(strongSelf.compBlockDict[operationIdentify]))([NSURL fileURLWithPath:decryptPath isDirectory:NO], rights, error);
                }
                
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                
                NSError *fileMgrError = nil;
                if (!isCustomDestPath) {
                    [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
                }
            }];
            
        }else // strongSelf.decryptCompletion == nil
        {
            NSError *fileMgrError = nil;
            if (!isCustomDestPath) {
                [[NSFileManager defaultManager] removeItemAtPath:destPath error:&fileMgrError];
            }
        }
    }];
}

// MARK: Sharing Service

- (void) shareFile:(NSURL *) filePath
          destPath:(NSURL *)destPath
         overwrite:(BOOL)isOverwrite
        recipients:(NSArray *)recipients
       permissions:(NXLRights *)permissions
       expiredDate:(NSDate *)date
    withCompletion:(shareFileCompletion)completion
{
    
    NSError *destPathError = nil;
    [self checkOperationDestPath:destPath isOverwrite:isOverwrite error:&destPathError];
    if (destPathError) {
        completion(nil, destPathError);
        return;
    }
    
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([NXLMetaData isNxlFile:filePath.path]) {
            __block NSString* owner = nil;
            [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
                if (error) {
                    NSLog(@"getOwner %@", error);
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    return;
                }
                owner = ownerId;
            }];
            
            NXLRights *rights = nil;
            
            dispatch_semaphore_t semi = dispatch_semaphore_create(0);
            
            // get rights from ad-hoc section in nxl
            __block NSDictionary *blockPolicySection = nil;
            [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error) {
                if (error) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    dispatch_semaphore_signal(semi);
                    return;
                } else {
                    blockPolicySection = policySection;
                }
                dispatch_semaphore_signal(semi);
            }];
            dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
            
            if (blockPolicySection == nil) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            
            NSArray* policies = [blockPolicySection objectForKey:@"policies"];
            if (policies.count == 0) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSDictionary* policy = [policies objectAtIndex:0];
            NSArray* namedRights = [policy objectForKey:@"rights"];
            NSArray* namedObs = [policy objectForKey:@"obligations"];
            rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
            
            BOOL isstward = [NXLUtil isStewardUser:owner clientProfile:self.profile];
            if (isstward || (rights && [rights SharingRight])) {
                NSDictionary *token = nil;
                NSError* err = nil;
                [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &err];
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (token) {
                    [strongSelf shareFile:filePath.path emails:recipients token:token permission:[rights getPermissions] owner:owner];
                    
                    if (strongSelf.compBlockDict[operationIdentify]) {
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(filePath, nil);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                    }
                } else {
                    ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, err);
                    [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                }
                
            }
        }
        else
        {  // not nxl file, do encrypt first, and then handle nxl header, like ad-hoc policy
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf encryptToNXLFile:filePath destPath:destPath overwrite:isOverwrite permissions:permissions withCompletion:^(NSURL *filePath, NSError *error) {
                if (filePath) {
                    __block NSString* owner = nil;
                    [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
                        if (error) {
                            NSLog(@"getOwner %@", error);
                        }
                        owner = ownerId;
                    }];
                    
                    NXLRights *rights = nil;
                    
                    dispatch_semaphore_t semi = dispatch_semaphore_create(0);
                    
                    // get rights from ad-hoc section in nxl
                    __block NSDictionary *blockPolicySection = nil;
                    [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error) {
                        if (error) {
                            //
                        } else {
                            blockPolicySection = policySection;
                        }
                        dispatch_semaphore_signal(semi);
                    }];
                    dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
                    
                    if (blockPolicySection == nil) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        return;
                    }
                    
                    
                    NSArray* policies = [blockPolicySection objectForKey:@"policies"];
                    if (policies.count == 0) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                        ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, error);
                        [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        return;
                    }
                    
                    NSDictionary* policy = [policies objectAtIndex:0];
                    NSArray* namedRights = [policy objectForKey:@"rights"];
                    NSArray* namedObs = [policy objectForKey:@"obligations"];
                    rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
                    
                    BOOL isstward = [NXLUtil isStewardUser:owner clientProfile:self.profile];
                    if (isstward || (rights && [rights SharingRight])) {
                        NSDictionary *token = nil;
                        NSError* err = nil;
                        [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &err];
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        if (token) {
                            [strongSelf shareFile:filePath.path emails:recipients token:token permission:[rights getPermissions] owner:owner];
                            
                            if (strongSelf.compBlockDict[operationIdentify]) {
                                ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(filePath, nil);
                                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                            }
                        } else {
                            ((shareFileCompletion)strongSelf.compBlockDict[operationIdentify])(nil, err);
                            [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                        }
                        
                    }
                }
            }];
        }
        
    });
    
}

- (void)shareFile:(NSString *)filePath emails:(NSArray *)emailsAddresses token:(NSDictionary *) token permission:(long) permissions owner:(NSString *) owner;
{
    // step1. generate sharing rest and store it
    NSMutableArray *recipientArray = [[NSMutableArray alloc] init];
    
    NSDictionary * recipient = nil;
    if (emailsAddresses.count) {
        for (NSInteger index = 0; index < emailsAddresses.count; ++index) {
            recipient = @{@"email":emailsAddresses[index]};
            [recipientArray addObject:recipient];
        }
    }
    
    NSString *udid = [token allKeys].firstObject;
    
    NSArray *fileNameCompont = [filePath componentsSeparatedByString:@"/" ];
    NSDictionary *sharedDocumentDic = @{DUID_KEY:udid, MEMBER_SHIP_ID_KEY:self.profile.defaultMembership.ID,
                                        PERMISSIONS_KEY:[NSNumber numberWithLong:permissions],
                                        METADATA_KEY:@"{}",
                                        FILENAME_KEY:fileNameCompont.lastObject,
                                        RECIPIENTS_KEY:recipientArray};
    NSError *error = nil;
    NSData *recipientsData = [NSJSONSerialization dataWithJSONObject:sharedDocumentDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *recipientsString = [[NSString alloc] initWithData:recipientsData encoding:NSUTF8StringEncoding];
    NSString *checkSUM = [NXLMetaData hmacSha256Token:token[udid] content:recipientsData];
    NSDictionary *sharingDic = @{USER_ID_KEY:self.profile.userId,
                                 TIKECT_KEY:self.profile.ticket,
                                 DEVICE_ID_KEY:[NXLCommonUtils deviceID],
                                 DEVICE_TYPE_KEY:[NXLCommonUtils getPlatformId],
                                 CHECK_SUM_KEY:checkSUM,
                                 SHARED_DOC_KEY:recipientsString};
    
    NXLSharingAPIRequest *sharingReq = [[NXLSharingAPIRequest alloc] init];
    [sharingReq requestWithObject:sharingDic Completion:^(id response, NSError *error) {
        if ([response isKindOfClass:[NXLSharingAPIResponse class]] && error ==nil ) {
            NXLLogAPIRequestModel *model = [[NXLLogAPIRequestModel alloc]init];
            model.duid = [[token allKeys] firstObject];
            model.owner = owner;
            model.operation = [NSNumber numberWithInteger:kNXLShareOperation];
            model.repositoryId = @" ";
            model.filePathId = @" ";
            model.accessTime = [NSNumber numberWithLongLong:([[NSDate date] timeIntervalSince1970] * 1000)];
            model.accessResult = [NSNumber numberWithInteger:1];
            model.filePath = filePath;
            model.fileName = fileNameCompont.lastObject;
            model.activityData = @"";
            model.ticket = self.profile.ticket;
            model.userID = self.profile.userId;
            NXLLogAPI *logAPI = [[NXLLogAPI alloc]init];
            [logAPI requestWithObject:model Completion:^(id response, NSError *error) {
                
            }];
            
        }
    }];
    
    
}

- (void) sharelocalFile:(NSURL *)filePath recipients:(NSArray *)recipients permissions:(NXLRights *)permissions tags:(NSString *)tags validateFileDict:(NSDictionary *)validateFileDateDict watermarkString:(NSString *)watermarkString shareAsAttachment:(BOOL)shouldShareAsAttachment comment:(NSString *)comment fullPath: (NSString *)fullPath filePathId:(NSString *)filePathId  withCompletion:(shareFileCompletion)completion {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath.path])
    {
        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
        completion(nil, error);
        return;
    }
    NSData *contentData = [NSData dataWithContentsOfURL:filePath];
    if (contentData == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
        completion(nil, error);
        return;
    }
    
    if ([NXLMetaData isNxlFile:filePath.path]) {
        NSError *error = nil;
        [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
        if (error) {
            completion(nil, error);
            return;
        }
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    NSMutableArray *emailsArray = [[NSMutableArray alloc] init];
    for (NSString *emailAddress in recipients) {
        NSDictionary *emailDict = @{@"email":emailAddress};
        [emailsArray addObject:emailDict];
    }
    NSString *fileName = [filePath lastPathComponent];
    NSDictionary *modelDict = @{RECIPIENTS_KEY:emailsArray,
                                USER_PROFILE_KEY:self.profile,
                                RIGHTS_KEY:permissions,
                                TAGS_KEY:tags,
                                CONTENT_DATA_KEY:contentData,
                                FILE_NAME_KEY:fileName,
                                COMMENT_KEY:comment?:@"",
                                SHARE_AS_ATTACHMENT:[NSNumber numberWithBool:shouldShareAsAttachment],
                                FILEPATH_KEY: fullPath,
                                FILEPATHID_KEY: filePathId,
                                VALIDATE_KEY: validateFileDateDict,
                                WATERMARK_KEY: watermarkString?:@""
                                };
    __weak typeof(self) weakSelf = self;
    NXLShareingLocalFileRequest *shareLocalRequest = [[NXLShareingLocalFileRequest alloc] init];
    [shareLocalRequest requestWithObject:modelDict Completion:^(id response, NSError *error) {
        if (error) {
            ((shareFileCompletion)(weakSelf.compBlockDict[operationIdentify]))(nil, error);
        }else
        {
            NXLShareingLocalFileResponse *sfResponse = (NXLShareingLocalFileResponse *)response;
            if (sfResponse.rmsStatuCode != 200) {
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedShareLocalFile userInfo:@{NSLocalizedDescriptionKey:sfResponse.rmsStatuMessage}];
                ((shareFileCompletion)(weakSelf.compBlockDict[operationIdentify]))(nil, error);
            }else{
                ((shareFileCompletion)(weakSelf.compBlockDict[operationIdentify]))(filePath, nil);
            }
        }
        
        [weakSelf.compBlockDict removeObjectForKey:operationIdentify];
    }];
    // share log will generate by RMS, so we don't need to write log again
}

- (void) sharelocalFileForPathId:(NSURL *)filePath recipients:(NSArray *)recipients permissions:(NXLRights *)permissions tags:(NSString *)tags validateFileDict:(NSDictionary *)validateFileDateDict watermarkString:(NSString *)watermarkString shareAsAttachment:(BOOL)shouldShareAsAttachment comment:(NSString *)comment fullPath: (NSString *)fullPath filePathId:(NSString *)filePathId withCompletion:(shareFileCompletionWithPathId)completion {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath.path])
    {
        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
        completion(nil, nil, error);
        return;
    }
    NSData *contentData = [NSData dataWithContentsOfURL:filePath];
    if (contentData == nil) {
        NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
        completion(nil, nil, error);
        return;
    }
    
    if ([NXLMetaData isNxlFile:filePath.path]) {
        NSError *error = nil;
        [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
        if (error) {
            completion(nil, nil, error);
            return;
        }
    }
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    NSMutableArray *emailsArray = [[NSMutableArray alloc] init];
    for (NSString *emailAddress in recipients) {
        NSDictionary *emailDict = @{@"email":emailAddress};
        [emailsArray addObject:emailDict];
    }
    NSString *fileName = [filePath lastPathComponent];
    NSDictionary *modelDict = @{RECIPIENTS_KEY:emailsArray,
                                USER_PROFILE_KEY:self.profile,
                                RIGHTS_KEY:permissions,
                                TAGS_KEY:tags,
                                CONTENT_DATA_KEY:contentData,
                                FILE_NAME_KEY:fileName,
                                COMMENT_KEY:comment?:@"",
                                SHARE_AS_ATTACHMENT:[NSNumber numberWithBool:shouldShareAsAttachment],
                                FILEPATH_KEY: fullPath,
                                FILEPATHID_KEY: filePathId,
                                VALIDATE_KEY: validateFileDateDict,
                                WATERMARK_KEY: watermarkString?:@""
                                };
    __weak typeof(self) weakSelf = self;
    NXLShareingLocalFileRequest *shareLocalRequest = [[NXLShareingLocalFileRequest alloc] init];
    [shareLocalRequest requestWithObject:modelDict Completion:^(id response, NSError *error) {
        if (error) {
            ((shareFileCompletionWithPathId)(weakSelf.compBlockDict[operationIdentify]))(nil, nil, error);
        }else
        {
            NXLShareingLocalFileResponse *sfResponse = (NXLShareingLocalFileResponse *)response;
            if (sfResponse.rmsStatuCode != 200) {
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedShareLocalFile userInfo:@{NSLocalizedDescriptionKey:sfResponse.rmsStatuMessage}];
                ((shareFileCompletionWithPathId)(weakSelf.compBlockDict[operationIdentify]))(nil, nil, error);
            }else{
                NSString *pathId = [[NSString alloc] initWithString:sfResponse.pathId];
                ((shareFileCompletionWithPathId)(weakSelf.compBlockDict[operationIdentify]))(filePath, pathId, nil);
            }
        }
        
        [weakSelf.compBlockDict removeObjectForKey:operationIdentify];
    }];
    // share log will generate by RMS, so we don't need to write log again
}

- (void)removeSharedFileRecipientsByFilePath:(NSURL *)filePath
                                  recipients:(NSArray *)recipients
                              withCompletion:(removeRecipientsCompletion)completion;
{
    if ([filePath absoluteString].length > 0 && recipients.count >0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:filePath.path])
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
            completion(error);
            return;
        }
        
        NSData *contentData = [NSData dataWithContentsOfURL:filePath];
        
        if (contentData == nil) {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
            completion(error);
            return;
        }
        
        if ([NXLMetaData isNxlFile:filePath.path]) {
            NSError *error = nil;
            [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
            if (error) {
                completion(error);
                return;
            }
        }
        else
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            completion(error);
            return;
        }
        
        NSDictionary *token = nil;
        NSError *error = nil;
        [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &error];
        
        NSString *userId = self.profile.userId;
        NSString *ticket = self.profile.ticket;
        NSString *duid = [[token allKeys] firstObject];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *recipientsArray = [[NSMutableArray alloc] init];
        
        for (NSString *recipient in recipients)
        {
            [dic setObject:recipient forKey:@"email"];
            [recipientsArray addObject:dic];
        }
        
        NSDictionary *parametersDic = @{USERID:userId,
                                        TICKET:ticket,
                                        DUID:duid,
                                        RECIPIENTS:recipientsArray
                                        };
        
        NXLRemoveRecipientsFromDocumentRequest *request = [[NXLRemoveRecipientsFromDocumentRequest alloc] init];
        
        [request requestWithObject:parametersDic Completion:^(id response, NSError *error) {
            
            
            NXLRemoveRecipientsFromDocumentResponse *Response = (NXLRemoveRecipientsFromDocumentResponse*)response;
            
            if (!error)
            {
                if(Response.rmsStatuCode == 200)
                {
                    completion(nil);
                }
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFailedRevokeRecipients userInfo:nil];
                    
                    completion(error);
                }
            }
            else
            {
                completion(error);
            }
        }];
    }
}

- (void)updateSharedFileRecipientsByDUID:(NSString *)duid
                           newRecipients:(NSArray *)newRecipients
                        removeRecipients:(NSArray *)removedRecipients                                 comment:(NSString *)comment
                          withCompletion:(updateSharingFileRecipientsCompletion)completion;
{
    NSDictionary *parametersDic = @{UPDATA_RECIPIENTS_DUID_KEY:duid,
                                    UPDATA_RECIPIENTS_NEW_RECIPIENTS_KEY:newRecipients,
                                    UPDATA_RECIPIENTS_REMOVE_RECIPIENTS_KEY:removedRecipients,
                                    UPDATA_RECIPIENTS_COMMENT_KEY:comment?:@""};

    
    NXLUpdateSharingRecipientsRequest *updateRecipientRequest = [[NXLUpdateSharingRecipientsRequest alloc] init];
    [updateRecipientRequest requestWithObject:parametersDic Completion:^(id response, NSError *error) {
        NXLUpdateSharingRecipientsResponse *updateRecipientRespons = (NXLUpdateSharingRecipientsResponse *)response;
        if (error) {
            completion(error);
        }else if (updateRecipientRespons.rmsStatuCode != 200) {
            error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorUpdateSharingRecipientsFailed userInfo:@{NSLocalizedDescriptionKey:updateRecipientRespons.rmsStatuMessage}];
            completion(error);
        }else{
            completion(nil);
        }
    }];
}
- (void)updateSharedFileRecipientsByFilePath:(NSURL *)filePath
                               newRecipients:(NSArray *)newRecipients
                            removeRecipients:(NSArray *)removedRecipients                                     comment:(NSString *)comment
                              withCompletion:(updateSharingFileRecipientsCompletion)completion
{
    if ([filePath absoluteString].length > 0 && (newRecipients.count || removedRecipients.count))
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:filePath.path])
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
            completion(error);
            return;
        }
        
        NSData *contentData = [NSData dataWithContentsOfURL:filePath];
        
        if (contentData == nil) {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
            completion(error);
            return;
        }
        
        if ([NXLMetaData isNxlFile:filePath.path]) {
            NSError *error = nil;
            [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
            if (error) {
                completion(error);
                return;
            }
        }
        else
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            completion(error);
            return;
        }
        
        NSDictionary *token = nil;
        NSError *error = nil;
        [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &error];
        
        NSString *userId = self.profile.userId;
        NSString *ticket = self.profile.ticket;
        NSString *duid = [[token allKeys] firstObject];
        
        
        [self updateSharedFileRecipientsByDUID:duid newRecipients:newRecipients removeRecipients:removedRecipients comment:comment withCompletion:^(NSError *error) {
            completion(error);
        }];
    }
}

- (void)revokingDocumentByFilePath:(NSURL *)filePath
                    withCompletion:(removeRecipientsCompletion)completion
{
    if ([filePath absoluteString].length > 0)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:filePath.path])
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
            completion(error);
            return;
        }
        
        NSData *contentData = [NSData dataWithContentsOfURL:filePath];
        
        if (contentData == nil) {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
            completion(error);
            return;
        }
        
        if ([NXLMetaData isNxlFile:filePath.path]) {
            NSError *error = nil;
            [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
            if (error) {
                completion(error);
                return;
            }
        }
        else
        {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorNotNXLFile userInfo:nil];
            completion(error);
            return;
        }
        
        NSDictionary *token = nil;
        NSError *error = nil;
        [NXLMetaData getFileToken:filePath.path tokenDict:&token clientProfile:self.profile error: &error];
        
        NSString *deviceID = [NXLCommonUtils deviceID];
        
//        NSString *deviceType = [[UIDevice currentDevice] model];
        NSString *duid = [[token allKeys] firstObject];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *recipientsArray = [[NSMutableArray alloc] init];
        
        NSDictionary *parametersDic = @{DUID:duid};
        
        NXLRevokingDocumentAPIRequest *request = [[NXLRevokingDocumentAPIRequest alloc] init];
        
        [request requestWithObject:parametersDic Completion:^(id response, NSError *error) {
            
            
            NXLRevokingDocumentAPIResponse *Response = (NXLRevokingDocumentAPIResponse*)response;
            
            if (!error)
            {
                if(Response.rmsStatuCode == 200)
                {
                    completion(nil);
                }
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFailedRevokeRecipients userInfo:nil];
                    
                    completion(error);
                }
            }
            else
            {
                completion(error);
            }
        }];
    }
}

- (void)revokingDocumentByDocumentId:(NSString *)duid
                      withCompletion:(removeRecipientsCompletion)completion
{
    if (duid.length > 0)
    {
        NSString *deviceID = [NXLCommonUtils deviceID];
//        NSString *deviceType = [[UIDevice currentDevice] model];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        NSMutableArray *recipientsArray = [[NSMutableArray alloc] init];
        
        NSDictionary *parametersDic = @{DUID:duid};
        
        NXLRevokingDocumentAPIRequest *request = [[NXLRevokingDocumentAPIRequest alloc] init];
        
        [request requestWithObject:parametersDic Completion:^(id response, NSError *error) {
            
            
            NXLRevokingDocumentAPIResponse *Response = (NXLRevokingDocumentAPIResponse*)response;
            
            if (!error)
            {
                if(Response.rmsStatuCode == 200)
                {
                    completion(nil);
                }
                else
                {
                    NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFailedRevokeRecipients userInfo:nil];
                    
                    completion(error);
                }
            }
            else
            {
                completion(error);
            }
        }];
    }
}

- (void) shareRepoFile:(NXLRepoFile *)repoFile
            recipients:(NSArray *)recipients
           permissions:(NXLRights *)permissions
                  tags:(NSString *)tags
           expiredDate:(NSDate *)date
     shareAsAttachment:(BOOL)shouldShareAsAttachment
               comment:(NSString *)comment
        withCompletion:(shareRepoFileCompletion)completion{
    
    NXLSharingRepositoryReqModel *model = [[NXLSharingRepositoryReqModel alloc] init];
    model.file = repoFile;
    model.recipients = recipients;
    model.rights = permissions;
    model.expireTime = date;
    model.asAttachment = shouldShareAsAttachment;
    model.comment = comment;
    model.profile = self.profile;
    
    NXLShareRepoFileRequest *request = [[NXLShareRepoFileRequest alloc] init];
    [request requestWithObject:model Completion:^(id response, NSError *error) {
        if(error){
            completion(nil, error);
        }else{
            NXLShareRepoFileResponse *shareRepoFileResponse = (NXLShareRepoFileResponse *)response;
            if (shareRepoFileResponse.rmsStatuCode == 200) {
                completion(shareRepoFileResponse.filePathId, nil);
            }else{
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedShareLocalFile userInfo:nil];
                completion(nil, error);
            }
        }
    }];
    
}

// MARK: ...

- (void) getNXLFileRights:(NSURL *)filePath withCompletion:(getNXLFileRightsCompletion)completion
{
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    __weak typeof(self) weakSelf = self;
    // get rights from ad-hoc section in nxl
    __block NSDictionary *blockPolicySection = nil;
    [NXLMetaData getPolicySection:filePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            ((getNXLFileRightsCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, false, error);
            [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
            
        } else {
            blockPolicySection = policySection;
            
            if (policySection == nil) {
                // create no policySection error
                // strongSelf.getNXLFileRightsCompletion(nil, error);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((getNXLFileRightsCompletion)strongSelf.compBlockDict[operationIdentify])(nil, false, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSArray *policies = [policySection objectForKey:@"policies"];
            if(policies.count == 0)
            {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
                ((getNXLFileRightsCompletion)strongSelf.compBlockDict[operationIdentify])(nil, false, error);
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
                return;
            }
            
            NSDictionary* policy = [policies objectAtIndex:0];
            NSArray* namedRights = [policy objectForKey:@"rights"];
            NSArray* namedObs = [policy objectForKey:@"obligations"];
            
            NXLRights *rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
            
            [self isStewardForNXLFile: filePath withCompletion:^(BOOL isSteward, NSError *error) {
                if(error) {
                    ((getNXLFileRightsCompletion)(strongSelf.compBlockDict[operationIdentify]))(nil, false, error);
                } else {
                    ((getNXLFileRightsCompletion)(strongSelf.compBlockDict[operationIdentify]))(rights, isSteward, nil);
                }
                
                [strongSelf.compBlockDict removeObjectForKey:operationIdentify];
            }];
            
        }
        
    }];
}

- (void)isStewardForNXLFile:(NSURL *)filePath withCompletion:(checkIsStewardCompletion)completion {
    [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
        if (error) {
            completion(NO, error);
        } else {
            if ([ownerId isEqualToString:self.profile.defaultMembership.ID]) {
                completion(YES, nil);
            } else {
                completion(NO, nil);
            }
        }
    }];
}

- (void) getStewardForNXLFile:(NSURL *)filePath withCompletion:(getNXLStewardCompletion)completion
{
    NSString *duid = nil;
    NSString *owner = nil;
    NSError *error = nil;
    [NXLMetaData getNxlFile:filePath.path duid:&duid publicAgrement:nil owner:&owner ml:nil error:&error];
    completion(owner, duid, error);
//    [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
//        if (error) {
//            completion(nil, error);
//        } else {
//            completion(ownerId, nil);
//        }
//    }];
    
}

- (BOOL) isNXLFile:(NSURL *)filePath {
    return [NXLMetaData isNxlFile:filePath.path];
}

- (BOOL) isNXLFileWithData:(NSData *)data {
    return [NXLMetaData isNxlFileWithData:data];
}

- (BOOL) isSessionTimeout
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (self.profile.ttl.doubleValue - timeInterval * 1000  > 0) {
        return NO;
    } else {
        return YES;
    }
}

// signOut
- (BOOL) signOut:(NSError **)error
{
    [[NXLClientSessionStorage sharedInstance] delClient:self];
    [[NXLTokenManager sharedInstance] cleanUserCacheData];
    return YES;
}

#pragma makr - Private function
- (void) checkOperationDestPath:(NSURL *)filePath isOverwrite:(BOOL)isOverwrite error:(NSError **)error
{
    assert(error);
    if (!isOverwrite) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:filePath.path])
        {
            *error = [[NSError alloc] initWithDomain:NXLSDKErrorNXLClientDomain code:NXLSDKErrorFileExisted userInfo:nil];
        }
        return;
    }
}

- (void)checkNXLFile:(NSURL *)nxlFilePath right:(NXLRIGHT)right error:( NSError * _Nonnull *)outError
{
    __weak typeof(self) weakSelf = self;
    __block NSString* owner = nil;
    [NXLMetaData getOwner:nxlFilePath.path complete:^(NSString *ownerId, NSError *error) {
        if (error) {
            if (outError) {
                *outError = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorReadOwnerFailed userInfo:nil];
            }
        }
        owner = ownerId;
    }];
    
    NXLRights *rights = nil;
    
    dispatch_semaphore_t semi = dispatch_semaphore_create(0);
    
    // get rights from ad-hoc section in nxl
    __block NSDictionary *blockPolicySection = nil;
    [NXLMetaData getPolicySection:nxlFilePath.path clientProfile:self.profile complete:^(NSDictionary *policySection, NSDictionary *classificationSection, NSError *error) {
        if (error) {
            if (outError) {
                *outError = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
            }
            dispatch_semaphore_signal(semi);
            return;
        } else {
            blockPolicySection = policySection;
        }
        dispatch_semaphore_signal(semi);
    }];
    dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
    
    if (blockPolicySection == nil) {
        if (outError) {
            *outError = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
        }
        return;
    }
    
    
    NSArray* policies = [blockPolicySection objectForKey:@"policies"];
    if (policies.count == 0) {
        if (outError) {
            *outError = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorUnableReadFilePolicy userInfo:nil];
        }
        return;
    }
    
    NSDictionary* policy = [policies objectAtIndex:0];
    NSArray* namedRights = [policy objectForKey:@"rights"];
    NSArray* namedObs = [policy objectForKey:@"obligations"];
    rights = [[NXLRights alloc]initWithRightsObs:namedRights obligations:namedObs];
    
    BOOL isstward = [NXLCommonUtils isStewardUser:owner clientProfile:self.profile];
    if (isstward || (rights && [rights getRight:right])) {
        return;
    }else
    {
        if (outError) {
            *outError = [[NSError alloc] initWithDomain:NXLSDKErrorNXLFileDomain code:NXLSDKErrorNoRight userInfo:nil];
        }
    }
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_profile forKey:@"profile"];
    [aCoder encodeObject:self.userTenant forKey:@"usertenant"];
    [aCoder encodeObject:self.userID forKey:@"userId"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.profile = [aDecoder decodeObjectForKey:@"profile"];
        _userTenant = [aDecoder decodeObjectForKey:@"usertenant"];
        _userID = [aDecoder decodeObjectForKey:@"userId"];
    }
    return self;
}

@end
