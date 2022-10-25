//
//  NXClient.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLClient.h"
#import "NXLProfile.h"
#import "NXLMetaData.h"
#import "NXLCommonUtils.h"
#import "NXLSharingAPI.h"
#import "NXLLogAPI.h"
#import "NXLSyncHelper.h"
#import "NXLCacheManager.h"
#import "NXLTenant.h"
#import "NXLClientSessionStorage.h"
#import "NXLoginPageViewController.h"
#import "NXLRemoveRecipientsFromDocumentAPI.h"
#import "NXLRevokingDocumentAPI.h"
#import "NXLFetchActivityLogInfoAPI.h"
#import "NXLUpdateSharingRecipientsAPI.h"
#import "NXLShareingLocalFileAPI.h"
#import "NSDictionary+Ext.h"
#import "NXLTokenManager.h"
#import "NXLShareRepoFileAPI.h"

@implementation NXLRepoFile

@end

@interface NXLClient()

@property(nonatomic, strong) NXLTenant *userTenant;
@property(nonatomic, strong) NSString *userID;

@property(nonatomic, strong) NXLProfile *profile;
@property(nonatomic, strong) NSMutableDictionary *compBlockDict;
@property(nonatomic, strong) NSMutableDictionary *reqDict;
@end

@implementation NXLClient
#pragma mark - INIT/GETTER/SETTER
- (NSMutableDictionary *) compBlockDict
{
    // first init
    @synchronized (self) {
        if (_compBlockDict == nil) {
            _compBlockDict = [[NSMutableDictionary alloc] init];
        }
        return _compBlockDict;
    }
}

- (NSMutableDictionary *)reqDict
{
    @synchronized (self) {
        if (_reqDict == nil) {
            _reqDict = [[NSMutableDictionary alloc] init];
        }
        return _reqDict;
    }
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

- (NXLClientIdpType)idpType
{
    return self.profile.idpType.longLongValue;
}

+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion
{
    NXLoginPageViewController * discoveryViewController = [[NXLoginPageViewController alloc]init];
    discoveryViewController.completion=completion;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:navController animated:YES completion:nil];
}
- (instancetype)initWithNXProfile:(NXLProfile *) profile tenantID:(NSString *) tenantID tenantName:(NSString *) tenantName
{
    self = [super init];
    if (self) {
        _profile = profile;
        _userID = profile.userId;
        NXLTenant *tenant = [[NXLTenant alloc] init];
        [tenant setValue:tenantID forKey:@"tenantID"];
        [tenant setValue:profile.rmserver forKey:@"rmsServerAddress"];
        [tenant setValue:tenantName forKey:@"tenantName"];
        _userTenant = tenant;
        [[NXLClientSessionStorage sharedInstance] storeClient:self];
    }
    return self;
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
    [request requestWithObject:model Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
        if(error){
            completion(error);
        }else{
            NXLSuperRESTAPIResponse *shareRepoFileResponse = (NXLSuperRESTAPIResponse *)response;
            if (shareRepoFileResponse.rmsStatuCode == 200) {
                completion(nil);
            }else{
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedShareLocalFile userInfo:nil];
                completion(error);
            }
        }
    }];
    
}

- (NSString *)sharelocalFile:(NSURL *)filePath
                  recipients:(NSArray *)recipients
                 permissions:(NXLRights *)permissions
                        tags:(NSString *)tags
            validateFileDict:(NSDictionary *)validateFileDateDict
             watermarkString:(NSString *)watermarkString
           shareAsAttachment:(BOOL)shouldShareAsAttachment
                     comment:(NSString *)comment
              withCompletion:(shareFileCompletion)completion {
    NSString *operationIdentify = [[NSUUID UUID] UUIDString];
    [self.compBlockDict setObject:completion forKey:operationIdentify];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (self && self.compBlockDict[operationIdentify]) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if(![fileManager fileExistsAtPath:filePath.path])
            {
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileNotExisted userInfo:nil];
                if (self.compBlockDict[operationIdentify]) {
                    shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                    callBack(nil,nil,nil,nil,error);
                    [self.compBlockDict removeObjectForKey:operationIdentify];
                    return;
                }
            }
            NSData *contentData = [NSData dataWithContentsOfURL:filePath];
            if (contentData == nil) {
                NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorFileSysDomain code:NXLSDKErrorFileDataEmpty userInfo:nil];
                if (self.compBlockDict[operationIdentify]) {
                    shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                    callBack(nil,nil,nil,nil,error);
                    [self.compBlockDict removeObjectForKey:operationIdentify];
                    return;
                }
            }
            
            if ([NXLMetaData isNxlFile:filePath.path]) {
                NSError *error = nil;
                [self checkNXLFile:filePath right:NXLRIGHTSHARING error:&error];
                if (error) {
                    if (self.compBlockDict[operationIdentify]) {
                        shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                        callBack(nil,nil,nil,nil,error);
                        [self.compBlockDict removeObjectForKey:operationIdentify];
                        return;
                    }
                }
            }
            
            
            NSMutableArray *emailsArray = [[NSMutableArray alloc] init];
            for (NSString *emailAddress in recipients) {
                NSDictionary *emailDict = @{@"email":emailAddress};
                [emailsArray addObject:emailDict];
            }
            NSString *fileName = [filePath lastPathComponent];
            if (emailsArray && self.profile && permissions && tags && contentData && fileName && validateFileDateDict) {
                NSDictionary *modelDict = @{RECIPIENTS_KEY:emailsArray,
                                            USER_PROFILE_KEY:self.profile,
                                            RIGHTS_KEY:permissions,
                                            TAGS_KEY:tags,
                                            CONTENT_DATA_KEY:contentData,
                                            FILE_NAME_KEY:fileName,
                                            COMMENT_KEY:comment?:@"",
                                            SHARE_AS_ATTACHMENT:[NSNumber numberWithBool:shouldShareAsAttachment],
                                            VALIDATE_KEY:validateFileDateDict,
                                            WATERMARK_KEY:watermarkString?:@""
                                            };
                __weak typeof(self) weakSelf = self;
                NXLShareingLocalFileRequest *shareLocalRequest = [[NXLShareingLocalFileRequest alloc] init];
                [self.reqDict setObject:shareLocalRequest forKey:operationIdentify];
                [shareLocalRequest requestWithObject:modelDict Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
                    [weakSelf.reqDict removeObjectForKey:operationIdentify];
                    if (error) {
                        if (weakSelf.compBlockDict[operationIdentify]) {
                            shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                            callBack(nil,nil,nil,nil,error);
                            [weakSelf.compBlockDict removeObjectForKey:operationIdentify];
                            return;
                        }
                    }else
                    {
                        NXLShareingLocalFileResponse *sfResponse = (NXLShareingLocalFileResponse *)response;
                        if (sfResponse.rmsStatuCode != 200) {
                            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedShareLocalFile userInfo:@{NSLocalizedDescriptionKey:sfResponse.rmsStatuMessage}];
                            if (weakSelf.compBlockDict[operationIdentify]) {
                                shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                                callBack(nil,nil,nil,nil,error);
                                [weakSelf.compBlockDict removeObjectForKey:operationIdentify];
                                return;
                            }
                        }else{
                            if (weakSelf.compBlockDict[operationIdentify]) {
                                shareFileCompletion callBack = self.compBlockDict[operationIdentify];
                                callBack(filePath,sfResponse.fileName,sfResponse.alreadySharedList,sfResponse.anewSharedList,nil);
                                [weakSelf.compBlockDict removeObjectForKey:operationIdentify];
                                return;
                            }
                        }
                    }
                }];
                
            }
            
        }
    });
    
    return operationIdentify;
    // share log will generate by RMS, so we don't need to write log again
    
}


- (NSString *) sharelocalFile:(NSURL *)filePath recipients:(NSArray *)recipients permissions:(NXLRights *)permissions tags:(NSString *)tags expiredDate:(NSDate *)date shareAsAttachment:(BOOL)shouldShareAsAttachment comment:(NSString *)comment withCompletion:(shareFileCompletion)completion {
    return [self sharelocalFile:filePath recipients:recipients permissions:permissions tags:tags validateFileDict:@{@"option":@0} watermarkString:nil shareAsAttachment:shouldShareAsAttachment comment:comment withCompletion:^(NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray, NSArray *newSharedArray,NSError *error) {
        completion(originalFilePath,sharedFileName,alreadySharedArray,newSharedArray,error);
    }];
}

- (void)updateSharedFileRecipientsByDUID:(NSString *)duid
                           newRecipients:(NSArray *)newRecipients
                        removeRecipients:(NSArray *)removedRecipients
                                 comment:(NSString *)comment
                          withCompletion:(updateSharingFileRecipientsCompletion)completion;
{
    NSDictionary *parametersDic = @{UPDATA_RECIPIENTS_DUID_KEY:duid,
                                    UPDATA_RECIPIENTS_NEW_RECIPIENTS_KEY:newRecipients,
                                    UPDATA_RECIPIENTS_REMOVE_RECIPIENTS_KEY:removedRecipients,
                                    UPDATA_RECIPIENTS_COMMENT_KEY:comment?:@""};
    
    NXLUpdateSharingRecipientsRequest *updateRecipientRequest = [[NXLUpdateSharingRecipientsRequest alloc] init];
    [updateRecipientRequest requestWithObject:parametersDic Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
        NXLUpdateSharingRecipientsResponse *updateRecipientRespons = (NXLUpdateSharingRecipientsResponse *)response;
        if (error) {
            completion(error);
        }else if (updateRecipientRespons.rmsStatuCode != 200) {
            NSError *error = [[NSError alloc] initWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorUpdateSharingRecipientsFailed userInfo:@{NSLocalizedDescriptionKey:updateRecipientRespons.rmsStatuMessage}];
            completion(error);
        }else{
            completion(nil);
        }
    }];
}

- (void)revokingDocumentByDocumentId:(NSString *)duid
                      withCompletion:(removeRecipientsCompletion)completion
{
    if (duid.length > 0)
    {
        NSDictionary *parametersDic = @{DUID:duid};
        
        NXLRevokingDocumentAPIRequest *request = [[NXLRevokingDocumentAPIRequest alloc] init];
        
        [request requestWithObject:parametersDic Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
            
            
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
    NSDictionary *sharedDocumentDic = @{DUID_KEY:udid, MEMBER_SHIP_ID_KEY:self.profile.individualMembership.ID,
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
    [sharingReq requestWithObject:sharingDic Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
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
            [logAPI requestWithObject:model Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
            }];

        }
    }];
  
    
}




- (void)isStewardForNXLFile:(NSURL *)filePath withCompletion:(checkIsStewardCompletion)completion
{
    [NXLMetaData getOwner:filePath.path complete:^(NSString *ownerId, NSError *error) {
        if (error) {
            completion(NO, error);
        }else{
            if ([ownerId isEqualToString:self.profile.individualMembership.ID]) {
                completion(YES, nil);
            }else{
                completion(NO, nil);
            }
        }
    }];
}

- (BOOL) isNXLFile:(NSURL *) filePath
{
    return [NXLMetaData isNxlFile:filePath.path];
}

// signOut
- (BOOL) signOut:(NSError **)error
{
    [[NXLClientSessionStorage sharedInstance] delClient:self];
    [[NXLTokenManager sharedInstance] cleanUserCacheData];
    return YES;
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

- (void)updateClientProfile:(NXLProfile *)clientProfile
{
    if (clientProfile) {
        self.profile = clientProfile;
        [[NXLClientSessionStorage sharedInstance] storeClient:self];
    }
}

- (void)cancelOperation:(NSString *)operatonIdentify
{
    if (operatonIdentify) {
        NXLSuperRESTAPIRequest *request = self.reqDict[operatonIdentify];
        [request cancelRequest];
        [self.reqDict removeObjectForKey:operatonIdentify];
        [self.compBlockDict removeObjectForKey:operatonIdentify];
    }
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
    [NXLMetaData getPolicySection:nxlFilePath.path clientProfile:self.profile sharedInfo:nil complete:^(NSDictionary *policySection, NSDictionary *classificationSection,NSError *error) {
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
    [aCoder encodeObject:self.userID forKey:@"userId"];
    [aCoder encodeObject:self.userTenant forKey:@"usertenant"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.profile = [aDecoder decodeObjectForKey:@"profile"];
        _userID = [aDecoder decodeObjectForKey:@"userId"];
        _userTenant = [aDecoder decodeObjectForKey:@"usertenant"];
    }
    return self;
}

@end
