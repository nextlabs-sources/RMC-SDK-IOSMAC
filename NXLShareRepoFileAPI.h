//
//  NXLShareRepoFileAPI.h
//  nxSDK
//
//  Created by Eren (Teng) Shi on 7/11/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLSuperRESTAPI.h"
#import "NXLRights.h"
//#import "NXLClient.h"

#import "NXLRepoFile.h"
#import "NXLProfile.h"


@interface NXLSharingRepositoryReqModel : NSObject
@property(nonatomic, strong) NXLRights *rights;
@property(nonatomic, strong) NXLRepoFile *file;
@property(nonatomic, strong) NSDate *expireTime;
@property(nonatomic, strong) NSArray *recipients;
@property(nonatomic, strong) NSString *comment;
@property(nonatomic, strong) NXLProfile *profile;
@property(nonatomic, assign) BOOL asAttachment;
@end

@interface NXLShareRepoFileRequest : NXLSuperRESTAPIRequest

@end

@interface NXLShareRepoFileResponse : NXLSuperRESTAPIResponse
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *filePathId;
@property(nonatomic, strong) NSString *transactionId;
@property(nonatomic, strong) NSArray *alreadySharedList;
@property(nonatomic, strong) NSArray *addedharedList;
@end
