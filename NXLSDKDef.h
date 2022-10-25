//
//  NXLSDKDef.h
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//
#import <TargetConditionals.h>
#ifndef NXLSDKDef_h
#define NXLSDKDef_h

// NXErrorDomain
#define NXLSDKErrorRestDomain            @"com.nextlabs.nxlsdk.rest.errors"
#define NXLSDKErrorNXLFileDomain         @"com.nextlabs.nxlsdk.nxlfile.errors"
#define NXLSDKErrorNXLClientDomain       @"com.nextlabs.nxlsdk.nxlclient.errors"
#define NXLSDKErrorFileSysDomain         @"com.nextlabs.nxlsdk.fileSys.errors"
// NXError code
typedef NS_ENUM(NSInteger, NXLSDKErrorCode) {
    
    // RMS REST ERROR CODE begin from 1000
    NXLSDKErrorFailedRequestMembership    = 1000,
    NXLSDKErrorFailedUploadLog            = 1001,
    NXLSDKErrorBadRequest                 = 1002,
    NXLSDKErrorUserSessionTimeout         = 1003,
    NXLSDKErrorFailedShareLocalFile       = 1004,
    NXLSDKErrorFailedRevokeRecipients     = 1005,
    NXLSDKErrorFailedFetchActivityLogInfo = 1006,
    
    // nxl error
    NXLSDKErrorNotNXLFile           = 2000,
    NXLSDKErrorFailedEncrypt        = 2001,
    NXLSDKErrorFailedDecrypt        = 2002,
    NXLSDKErrorUnableGetFileType    = 2003,
    NXLSDKErrorUnableReadFilePolicy = 2004,
    NXLSDKErrorUnknown              = 2005,
    NXLSDKErrorUnableWritePolicy    = 2006,
    NXLSDKErrorToken                = 2007,
    NXLSDKErrorReadOwnerFailed      = 2008,
    NXLSDKErrorNoSuchFile           = 2009,
    NXLSDKErrorAlreadyNXLFile       = 2010,
    NXLSDKErrorNoRight              = 2011,
    NXLSDKErrorUpdateSharingRecipientsFailed = 2012,
    NXLSDKErrorNOTPermission = 2013,
    
    // nxl sdk client error
    NXLSDKErrorCanceled = 3001,
    NXLSDKErrorFileExisted = 3002,
    NXLSDKErrorInvalidDestPath = 3003,
    
    // file sys error
    NXLSDKErrorFileNotExisted = 4001,
    NXLSDKErrorFileDataEmpty = 4002,
};

// user operation
typedef NS_ENUM(NSInteger, nxlActivityOperation)
{
    kNXLProtectOperation = 1,
    kNXLShareOperation = 2,
    kNXLRemoveUserOperation = 3,
    kNXLViewOperation = 4,
    kNXLPrintOpeartion = 5,
    kNXLDownloadOperation = 6,
    kNXLEditSaveOperation = 7,
    kNXLRevokeOperation = 8,
    kNXLDecryptOperation = 9,
    kNXLCopyContentOpeartion = 10,
    kNXLCaptureScreenOpeartion = 11,
    kNXLClassifyOperation = 12,
    kNXLReShareOperation = 13
};

// REST API
#define RESTAPIFLAGHEAD                 @"REST-FLAG"
#define RESTAPITAIL                     @"/service"
#define RESTCLIENT_ID_HEAD              @"clientId"
#define RESTSUPERBASE                   @"RESTSUPERBASE"
#define REST_PLATFORM_HEAD              @"platformId"

#define  NXL_KEYCHAIN_PROFILES_SERVICE      @"NXL_com.nextlabs.nxrmc.service.profiles"
#define  NXL_KEYCHAIN_DEVICE_ID             @"Nextlabs.iOS.DeviceID"
#define  NXL_KEYCHAIN_PROFILES              @"NXL_com.nextlabs.nxrmc.profiles"

// The extension of REST API cache file
#define NXLSDK_CACHE_EXTENSION @".restback"

// for nxl file
#define  NXLFILEEXTENSION               @".nxl"

#define APPLICATION_NAME                @"RMC iOS"
#define APPLICATION_PUBLISHER           @"NextLabs"
#define APPLICATION_PATH                @"RMC iOS"

// test for debug
//#define DEFAULT_TENANT_ID       @"skydrm.com"
//#define DEFAULT_SKYDRM          @"https://rmtest.nextlabs.solutions"

// test for release
//#define DEFAULT_TENANT_ID       @"testdrm.com"
//#define DEFAULT_SKYDRM          @"https://testdrm.com"

// really
#define DEFAULT_TENANT_ID       @"skydrm.com"
#define DEFAULT_SKYDRM          @"https://www.skydrm.com"

//#define DEFAULT_SKYDRM                  @"https://rms-centos7308.qapf1.qalab01.nextlabs.com:8443"
//#define DEFAULT_TENANT_ID               @"3233042f-0308-479c-8484-a83d28053065"

#define SPECIFIC_TENANT                @"specific_tenant"

//weak-strong.
#define WeakObj(obj) __weak typeof(obj) obj##Weak = obj;
#define StrongObj(obj) __strong typeof(obj) obj = obj##Weak;

#if TARGET_OS_OSX
#define RMC_TENANTNAME [NXLClient currentNXLClient:nil].userTenant.tenantID
#define RMC_DEVICT_ID [[NSHost currentHost] localizedName]
#endif

#if TARGET_OS_IOS
#define RMC_TENANTNAME [NXLCommonUtils currentTenant]
#define RMC_DEVICT_ID [UIDevice currentDevice].name
#endif 

// The RMS config NSUserProfile Key
#define NXRMS_ADDRESS_KEY @"NXRMS_ADDRESS_KEY"

#endif /* NXLSDKDef_h */
