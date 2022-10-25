//
//  NXLClient.h
//  nxlMacSDK
//
//  Created by nextlabs on 14/12/2016.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Cocoa/Cocoa.h>

#import "../../../NXLRights.h"
#import "../../../NXLTenant.h"

@class NXLRepoFile;

@class NXLClient;
typedef void(^NXLClientLogInCompletion)(NXLClient *client, NSError *error);
typedef void(^NXLClientSignUpCompletion)(NXLClient *client, NSError *error);
typedef void(^encryptToNXLFileCompletion) (NSURL *filePath, NSError *error);
typedef void(^decryptNXLFileCompletion) (NSURL *filePath, NXLRights *rights, NSError *error);

typedef void(^getNXLFileRightsCompletion)(NXLRights *rights, BOOL isOwner, NSError *error);

typedef void(^shareFileCompletion) (NSURL *filePath, NSError *error);
typedef void(^shareFileCompletionWithPathId) (NSURL *filePath, NSString *pathId, NSError *error);
typedef void(^NXLCheckValidTokenCompletion)(NSString *message, NSError *error);
typedef void(^checkIsStewardCompletion)(BOOL isSteward, NSError *error);
typedef void(^getNXLStewardCompletion)(NSString *steward, NSString *duid, NSError *error);
typedef void(^removeRecipientsCompletion)(NSError *error);
typedef void(^updateSharingFileRecipientsCompletion)(NSError *error);
typedef void(^removeRevokingDocumentCompletion)(NSError *error);

typedef void(^shareRepoFileCompletion)(NSString *pathId, NSError *error);

@class NXLTenant;

@class NXLProfile;
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
@property(nonatomic, strong) NXLProfile *profile;

/*
 caller should call this API to do login.
 */
+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion;

/*
 caller should call this API to do login.
 */
+ (void) logInNXLClientWithCompletion:(NXLClientLogInCompletion)completion
                                 view:(NSView *)view;

/*
 caller should call this API to do signUp.
 */
+ (void) signUpNXLClientWithCompletion:(NXLClientSignUpCompletion)completion;

/*
 recover NXLClient object from storage (like key chain)
 if no object or timed out, return nil, then check error.
 */
+ (NXLClient *)currentNXLClient:(NSError **)error;

/**
 Purpose:signOut
 
 @param error If login failed returns a error
 */

- (BOOL)signOut:(NSError **)error;

/*
 caller should call this API to do valid token check.
 */
+ (void)checkValidToken:(NSString *)token WithCompletion:(NXLCheckValidTokenCompletion)completion;

/*
 */
- (void) encryptToNXLFile:(NSURL *)filePath
                 destPath:(NSURL *)destPath
                overwrite:(BOOL)isOverwrite
              permissions:(NXLRights *)permissions
           withCompletion:(encryptToNXLFileCompletion)completion;

- (void) decryptNXLFile:(NSURL *)filePath
               destPath:(NSURL *)destPath
              overwrite:(BOOL)isOverwrite
         withCompletion:(decryptNXLFileCompletion) completion;

// MARK: Sharing Service

- (void) shareFile:(NSURL *) filePath
          destPath:(NSURL *)destPath
         overwrite:(BOOL)isOverwrite
        recipients:(NSArray *)recipients
       permissions:(NXLRights *)permissions
       expiredDate:(NSDate *)date
    withCompletion:(shareFileCompletion)completion;

- (void)sharelocalFile:(NSURL *)filePath
            recipients:(NSArray *)recipients
           permissions:(NXLRights *)permissions
                  tags:(NSString *)tags
      validateFileDict:(NSDictionary *)validateFileDateDict
       watermarkString:(NSString *)watermarkString
     shareAsAttachment:(BOOL)shouldShareAsAttachment
               comment:(NSString *)comment
               fullPath: (NSString *)fullPath
            filePathId:(NSString *)filePathId
        withCompletion:(shareFileCompletion)completion;

- (void)sharelocalFileForPathId:(NSURL *)filePath
                     recipients:(NSArray *)recipients
                    permissions:(NXLRights *)permissions
                           tags:(NSString *)tags
               validateFileDict:(NSDictionary *)validateFileDateDict
                watermarkString:(NSString *)watermarkString
              shareAsAttachment:(BOOL)shouldShareAsAttachment
                        comment:(NSString *)comment
                       fullPath:(NSString *)fullPath
                     filePathId:(NSString *)filePathId
                 withCompletion:(shareFileCompletionWithPathId)completion;

- (void)removeSharedFileRecipientsByFilePath:(NSURL *)filePath
                                  recipients:(NSArray *)recipients
                              withCompletion:(removeRecipientsCompletion)completion;


- (void)updateSharedFileRecipientsByFilePath:(NSURL *)filePath
                               newRecipients:(NSArray *)newRecipients
                            removeRecipients:(NSArray *)removedRecipients
                                     comment:(NSString *)comment
                              withCompletion:(updateSharingFileRecipientsCompletion)completion;

- (void)updateSharedFileRecipientsByDUID:(NSString *)duid
                           newRecipients:(NSArray *)newRecipients
                        removeRecipients:(NSArray *)removedRecipients
                                 comment:(NSString *)comment
                          withCompletion:(updateSharingFileRecipientsCompletion)completion;

/**
 Purpose:Revoking a document
 
 @param filePath The file local path.
 @param completion A completion callback block.
 */
- (void)revokingDocumentByFilePath:(NSURL *)filePath
                    withCompletion:(removeRecipientsCompletion)completion;

/**
 Purpose:Revoking a document
 
 @param duid The Document Id.
 @param completion A completion callback block.
 */
- (void)revokingDocumentByDocumentId:(NSString *)duid
                      withCompletion:(removeRecipientsCompletion)completion;

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

// MARK: ...

- (void) getNXLFileRights:(NSURL *)filePath withCompletion:(getNXLFileRightsCompletion)completion;

- (void) isStewardForNXLFile:(NSURL *)filePath withCompletion:(checkIsStewardCompletion)completion;

- (void) getStewardForNXLFile:(NSURL *)filePath withCompletion:(getNXLStewardCompletion)completion;

- (BOOL) isNXLFile:(NSURL *)filePath;
- (BOOL) isNXLFileWithData:(NSData *)data;
@end
