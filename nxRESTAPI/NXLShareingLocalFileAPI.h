//
//  NXLShareingLocalFileAPI.h
//  nxSDK
//
//  Created by EShi on 12/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLSuperRESTAPI.h"

#define USER_PROFILE_KEY @"USER_PROFILE_KEY"
#define EXPIRE_TIME_KEY @"EXPIRE_TIME_KEY"
#define RIGHTS_KEY      @"RIGHTS_KEY"
#define TAGS_KEY        @"TAGS_KEY"
#define RECIPIENTS_KEY  @"RECIPIENTS_KEY"
#define CONTENT_DATA_KEY @"CONTENT_DATA_KEY"
#define FILE_NAME_KEY    @"FILE_NAME_KEY"
#define COMMENT_KEY      @"COMMENT_KEY"
#define SHARE_AS_ATTACHMENT @"SHARE_AS_ATTACHMENT"
#define FILEPATH_KEY        @"FILEPATH_KEY"
#define FILEPATHID_KEY      @"FILEPATHID_KEY"
#define VALIDATE_KEY        @"VALIDATE_KEY"
#define WATERMARK_KEY       @"WATERMARK_KEY"

@interface NXLShareingLocalFileRequest : NXLSuperRESTAPIRequest

@end

@interface NXLShareingLocalFileResponse : NXLSuperRESTAPIResponse
@property(nonatomic, strong) NSNumber *serviceTime;
@property(nonatomic, strong) NSString *duid;
@property(nonatomic, strong) NSString *pathId;
@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSArray *alreadySharedList;
@property(nonatomic, strong) NSArray *anewSharedList;
- (void)analysisResponseData:(NSData *)responseData;
@end
