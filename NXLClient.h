//
//  NXClient.h
//  nxrmc
//
//  Created by EShi on 8/30/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLRights.h"
#import "NXLProfile.h"
#import "NXLFetchActivityLogInfoDataModel.h"

#import "NXLRepoFile.h"

//@interface NXLRepoFile : NSObject
//@property(nonatomic, strong) NSString *fileName;
//@property(nonatomic, strong) NSString *repoId;
//@property(nonatomic, strong) NSString *filePath;
//@property(nonatomic, strong) NSString *filePathId;
//@end



@class NXLClient;
typedef void(^encryptToNXLFileCompletion) (NSURL *filePath, NSError *error);
typedef void(^decryptNXLFileCompletion) (NSURL *filePath, NXLRights *rights, NSError *error);
typedef void(^shareFileCompletion) (NSURL *originalFilePath,NSString *sharedFileName,NSArray *alreadySharedArray, NSArray *newSharedArray,NSError *error);
typedef void(^shareRepoFileCompletion)(NSError *error);
typedef void(^getNXLFileRightsCompletion)(NXLRights *rights, NSError *error);
typedef void(^NXLClientLogInCompletion)(NXLClient *client, NSError *error);
typedef void(^removeRecipientsCompletion)(NSError *error);
typedef void(^updateSharingFileRecipientsCompletion)(NSError *error);
typedef void(^removeRevokingDocumentCompletion)(NSError *error);
typedef void(^fetchActivityLogInfoCompletion)(NXLFetchLogInfoResultModel *resultModel,NSError *error);
typedef void(^checkIsStewardCompletion)(BOOL isSteward, NSError *error);

@class NXLTenant;
typedef NS_ENUM(NSInteger, NXLClientIdpType)
{
    NXLClientIdpTypeBasic = 0,
    NXLClientIdpTypeSAML = 1,
    NXLClientIdpTypeGoogle = 2,
    NXLClientIdpTypeFaceBook = 3,
    NXLClientIdpTypeYahoo = 4,
    
};

@interface NXLClient : NSObject
@property(nonatomic, strong, readonly) NXLTenant *userTenant;
@property(nonatomic, strong, readonly) NSString *userID;
@property(nonatomic, assign, readonly) NXLClientIdpType idpType;

/**
 Purpose:Init Method for NXL Users(only used for nx self)
 
 @param profile A vcard of NXLlClient.
 @param tenantID  A tenant id.
 */
- (instancetype)initWithNXProfile:(NXLProfile *) profile tenantID:(NSString *) tenantID tenantName:(NSString *) tenantName;

/**
 Purpose:Login For NXL Client.
 
 @param error Get current NXLClient.
 */
+ (NXLClient *)currentNXLClient:(NSError **)error;

/**
 Purpose:Login For NXL Client

 @param completion A completion callback block.
 */
+ (void)logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion;


/**
 Purpose:Share repository file
 
 @param repoFile The repository file.
 @param recipients A array of sharedFile members.
 @param permissions Whether you have a permission to operate a file
 @param tags
 @param expiredDate The date of expiredDate.
 @param shareAsAttachment
 @param completion A completion callback block.
 */
- (void) shareRepoFile:(NXLRepoFile *)repoFile
            recipients:(NSArray *)recipients
           permissions:(NXLRights *)permissions
                  tags:(NSString *)tags
           expiredDate:(NSDate *)date
     shareAsAttachment:(BOOL)shouldShareAsAttachment
               comment:(NSString *)comment
        withCompletion:(shareRepoFileCompletion)completion;

/**
 Purpose:Share LocalFile
 
 @param filePath The file local path.
 @param recipients A array of sharedFile members.
 @param permissions Whether you have a permission to operate a file
 @param tags
 @param expiredDate The date of expiredDate.
 @param shareAsAttachment
 @param completion A completion callback block.
 */
- (NSString *)sharelocalFile:(NSURL *)filePath
            recipients:(NSArray *)recipients
           permissions:(NXLRights *)permissions
                  tags:(NSString *)tags
           expiredDate:(NSDate *)date
     shareAsAttachment:(BOOL)shouldShareAsAttachment
               comment:(NSString *)comment
        withCompletion:(shareFileCompletion)completion;

- (NSString *)sharelocalFile:(NSURL *)filePath
                  recipients:(NSArray *)recipients
                 permissions:(NXLRights *)permissions
                        tags:(NSString *)tags
            validateFileDict:(NSDictionary *)validateFileDateDict
             watermarkString:(NSString *)watermarkString
           shareAsAttachment:(BOOL)shouldShareAsAttachment
                     comment:(NSString *)comment
              withCompletion:(shareFileCompletion)completion;


- (void)updateSharedFileRecipientsByDUID:(NSString *)duid
                               newRecipients:(NSArray *)newRecipients
                            removeRecipients:(NSArray *)removedRecipients
                                     comment:(NSString *)comment
                              withCompletion:(updateSharingFileRecipientsCompletion)completion;


/**
 Purpose:Revoking a document
 
 @param duid The Document Id.
 @param completion A completion callback block.
 */
- (void)revokingDocumentByDocumentId:(NSString *)duid
                    withCompletion:(removeRecipientsCompletion)completion;

/**
 Purpose: Check if current user is steward for nxl file
 
 @param filePath The file local path.
 @param completion A completion callback block.
 */
- (void)isStewardForNXLFile:(NSURL *)filePath withCompletion:(checkIsStewardCompletion)completion;

/**
 Purpose:Judging a NXL file
 
 @param filePath The file local path.
 */
- (BOOL)isNXLFile:(NSURL *)filePath;

/**
 Purpose:signOut
 
 @param error If login failed returns a error
 */
- (BOOL)signOut:(NSError **)error;

/**
 Purpose:judging session time out
 
 */
- (BOOL)isSessionTimeout;

/** 
 
*/
- (void)updateClientProfile:(NXLProfile *)clientProfile;

- (void)cancelOperation:(NSString *)operatonIdentify;
@end
