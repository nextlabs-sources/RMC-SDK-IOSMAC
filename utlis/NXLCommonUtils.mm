//
//  NXCommonUtils.m
//  nxrmc
//
//  Created by Kevin on 15/5/12.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLCommonUtils.h"

#import <CoreData/CoreData.h>
#import <string>

#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <netdb.h>


#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#import "NXLSDKDef.h"
#import "NXLKeyChain.h"


#import <MobileCoreServices/MobileCoreServices.h>
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+Codec.h"
#import "NXLTokenManager.h"

#define FILETYPE_HSF            @"hoopsviewer/x-hsf"
#define NXLRMS_TENANT_KEY       @"com.skydrm.rmcent.NEXTLABS_TENANT_ID_KEY"


@implementation NXLCommonUtils

+ (UIView*) createWaitingView
{
    CGRect r = [UIScreen mainScreen].bounds;
    UIView* bg = [[UIView alloc] initWithFrame: r];
    [bg setTag:8808];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //  activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
    
    activityView.frame = CGRectMake(r.size.width /2 - 15, r.size.height /2 - 15, 30.0f, 30.0f);
    
    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
    waitingbg.frame = CGRectMake(r.size.width/2 -30, r.size.height /2 - 30, 60, 60);
    
    [bg addSubview:waitingbg];
    [bg addSubview:activityView];
    
    
    [activityView startAnimating];
    
    return bg;
    
}

+ (UIView*) createWaitingView:(CGFloat)sidelength {
    CGRect r = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(r.size.width/2 - sidelength/2, r.size.height/2 - sidelength/2, sidelength, sidelength);
    
    UIView* bg = [[UIView alloc] initWithFrame:frame];
    [bg setTag:8808];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    //  activityView.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
    
    activityView.frame = CGRectMake(0, 0, sidelength, sidelength);
    
    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
    waitingbg.frame = CGRectMake(0,0, sidelength, sidelength);
    
    [activityView startAnimating];
    [bg addSubview:waitingbg];
    [bg addSubview:activityView];
    
    return bg;
}

+ (UIView*) createWaitingViewWithCancel:(id)target selector:(SEL)selector inView:(UIView*)view
{
    UIView* bg = [[UIView alloc] init];
    [bg setTag:8808];
    bg.translatesAutoresizingMaskIntoConstraints = NO;
    bg.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
    waitingbg.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add subview
    [bg addSubview:waitingbg];
    [bg addSubview:activityView];
    [view addSubview:bg];
    
    
    // add cancel buttonr
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"Cancel" forState:UIControlStateNormal];
    [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundColor:[UIColor redColor]];
    [bg addSubview:btn];
    
    //do auto layout
    [self doAutoLayoutForWaitingView:view backgroundView:bg waitingBg:waitingbg activityView:activityView];
    
    //do auto layout for cancel button
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:btn
                       attribute:NSLayoutAttributeWidth
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:100]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:btn
                       attribute:NSLayoutAttributeHeight
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:30]];
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:btn
                       attribute:NSLayoutAttributeCenterX
                       relatedBy:NSLayoutRelationEqual
                       toItem:bg
                       attribute:NSLayoutAttributeCenterX
                       multiplier:1
                       constant:0]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:btn
                       attribute:NSLayoutAttributeTop
                       relatedBy:NSLayoutRelationEqual
                       toItem:waitingbg
                       attribute:NSLayoutAttributeBottom
                       multiplier:1
                       constant:20]];
    [activityView startAnimating];
    
    return bg;
}

+(NSString *) currentTenant
{
    NSString *tenant = [[NSUserDefaults standardUserDefaults] objectForKey:NXLRMS_TENANT_KEY];
    return (tenant?tenant:@"");
    
}

+(void) updateTenant:(NSString *) tenant
{
    [[NSUserDefaults standardUserDefaults] setObject:tenant forKey:NXLRMS_TENANT_KEY];
}




+ (void) removeWaitingViewInView:(UIView *) view
{
    if ([view viewWithTag:8808]) {
        [[view viewWithTag:8808] removeFromSuperview];
    }
}

+(BOOL) waitingViewExistInView:(UIView *)view
{
    if([view viewWithTag:8808])
    {
        return YES;
    }else
    {
        return NO;
    }
}

+ (UIView*) createWaitingViewInView:(UIView*)view
{
    if ([view viewWithTag:8808]) {
        return [view viewWithTag:8808];
    }
    
    UIView* bg = [[UIView alloc] init];
    [bg setTag:8808];
    bg.translatesAutoresizingMaskIntoConstraints = NO;
    bg.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView* waitingbg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WaitingBk"]];
    waitingbg.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add subview
    [bg addSubview:waitingbg];
    [bg addSubview:activityView];
    [view addSubview:bg];
    
    //do autolay out
    [self doAutoLayoutForWaitingView:view backgroundView:bg waitingBg:waitingbg activityView:activityView];
    
    //start animating
    [activityView startAnimating];
    
    return bg;
}

//barButtonItem only for iPad, other please pass nil.
+ (void)showAlertView:(NSString *)title
              message:(NSString *)message
                style:(UIAlertControllerStyle)style
        OKActionTitle:(NSString *)okTitle
    cancelActionTitle:(NSString*)cancelTitle
       OKActionHandle:(void (^ __nullable)(UIAlertAction *action))OKActionHandler
   cancelActionHandle:(void (^ __nullable)(UIAlertAction *action))cancelActionHandler
     inViewController:(UIViewController *)controller
             position:(UIView *)sourceView;
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:style];
    if (cancelTitle) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:cancelActionHandler];
        [alertController addAction:cancelAction];
    }
    if (okTitle) {
        UIAlertAction *OKAction = [UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDefault handler:OKActionHandler];
        [alertController addAction:OKAction];
    }
  
    if ([NXLCommonUtils isiPad] && sourceView != nil) {
        alertController.popoverPresentationController.barButtonItem = nil;
        alertController.popoverPresentationController.sourceView = sourceView;
    }
    [controller presentViewController:alertController animated:YES completion:nil];
}
+(NSString *) currentBundleDisplayName
{
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentDisplayName = [infoDic objectForKey:@"CFBundleDisplayName"];
    return currentDisplayName;
    
}
+ (void)doAutoLayoutForWaitingView:(UIView*)view backgroundView:(UIView*)bg waitingBg:(UIView*)waitingbg activityView:(UIView*)activityView
{
    // do autlayout
    // add activityView
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:activityView
                       attribute:NSLayoutAttributeWidth
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:30]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:activityView
                       attribute:NSLayoutAttributeHeight
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:30]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:activityView
                       attribute:NSLayoutAttributeCenterX
                       relatedBy:NSLayoutRelationEqual
                       toItem:bg
                       attribute:NSLayoutAttributeCenterX
                       multiplier:1
                       constant:0]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:activityView
                       attribute:NSLayoutAttributeCenterY
                       relatedBy:NSLayoutRelationEqual
                       toItem:bg
                       attribute:NSLayoutAttributeCenterY
                       multiplier:1
                       constant:0]];
    
    // add bg
    [view addConstraint:[NSLayoutConstraint
                         constraintWithItem:bg
                         attribute:NSLayoutAttributeTop
                         relatedBy:NSLayoutRelationEqual
                         toItem:view
                         attribute:NSLayoutAttributeTop
                         multiplier:1
                         constant:0]];
    
    [view addConstraint:[NSLayoutConstraint
                         constraintWithItem:bg
                         attribute:NSLayoutAttributeBottom
                         relatedBy:NSLayoutRelationEqual
                         toItem:view
                         attribute:NSLayoutAttributeBottom
                         multiplier:1
                         constant:0]];
    
    [view addConstraint:[NSLayoutConstraint
                         constraintWithItem:bg
                         attribute:NSLayoutAttributeTrailing
                         relatedBy:NSLayoutRelationEqual
                         toItem:view
                         attribute:NSLayoutAttributeTrailing
                         multiplier:1
                         constant:0]];
    [view addConstraint:[NSLayoutConstraint
                         constraintWithItem:bg
                         attribute:NSLayoutAttributeLeading
                         relatedBy:NSLayoutRelationEqual
                         toItem:view
                         attribute:NSLayoutAttributeLeading
                         multiplier:1
                         constant:0]];
    
    // add waitingbg
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:waitingbg
                       attribute:NSLayoutAttributeWidth
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:60]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:waitingbg
                       attribute:NSLayoutAttributeHeight
                       relatedBy:NSLayoutRelationEqual
                       toItem:nil
                       attribute:NSLayoutAttributeNotAnAttribute
                       multiplier:1
                       constant:60]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:waitingbg
                       attribute:NSLayoutAttributeCenterX
                       relatedBy:NSLayoutRelationEqual
                       toItem:bg
                       attribute:NSLayoutAttributeCenterX
                       multiplier:1
                       constant:0]];
    
    [bg addConstraint:[NSLayoutConstraint
                       constraintWithItem:waitingbg
                       attribute:NSLayoutAttributeCenterY
                       relatedBy:NSLayoutRelationEqual
                       toItem:bg
                       attribute:NSLayoutAttributeCenterY
                       multiplier:1
                       constant:0]];

}

+ (BOOL)isValidateEmail:(NSString *)email
{
    if (!email.length) {
        return NO;
    }
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
}


+ (void) deleteFilesAtPath:(NSString *) directory
{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    BOOL ret = [fileManager removeItemAtPath:directory error:nil];
    if (!ret) {
        NSLog(@"delete %@ failed", directory);
    }
}


+ (NSNumber *) calculateCachedFileSizeAtPath:(NSString *)folderPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSNumber *folderSize = [NSNumber numberWithUnsignedLongLong:0];
    
    NSArray* array = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
    for(int i = 0; i < array.count; i++)
    {
        NSString *fullPath = [folderPath stringByAppendingPathComponent:[array objectAtIndex:i]];
        
        BOOL isDir;
        if ( !([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) )
        {
            NSDictionary *fileAttributeDic = [fileManager attributesOfItemAtPath:fullPath error:nil];
            folderSize = [NSNumber numberWithUnsignedLongLong:[folderSize unsignedLongLongValue] + fileAttributeDic.fileSize];
        }
        else
        {
            folderSize = [NSNumber numberWithUnsignedLongLong:[folderSize unsignedLongLongValue] + [[self calculateCachedFileSizeAtPath:fullPath] unsignedLongLongValue]];
        }
    }
    return folderSize;
}



+ (NSArray*) getStoredProfiles
{
    NSMutableDictionary* dict = [NXLKeyChain load:NXL_KEYCHAIN_PROFILES_SERVICE];  // get info from key chain
    NSData* data = [dict objectForKey:NXL_KEYCHAIN_PROFILES];  // get stored value, this is binary data of all profiles
    NSArray* profiles = [NSKeyedUnarchiver unarchiveObjectWithData:data];  // unarchive
    
    NSMutableArray* ary = [NSMutableArray array];
    for (NXLProfile* profile in profiles) {
//        NSLog(@"uname: %@, domain: %@, sid: %@, rmserver: %@", profile.userName, profile.domain, profile.sid, profile.rmserver);
        
        [ary addObject:profile];
    }
    
    return ary;
    
}

+ (void) storeProfile:(NXLProfile *)profile
{
    if (!profile) {
        return;
    }
    
    NSArray* profiles = [NXLCommonUtils getStoredProfiles];  // get existing profiles
    NSMutableArray* newProfiles = [NSMutableArray arrayWithArray:profiles];
    for (NXLProfile* p in newProfiles) {
        if ([p equalProfile:profile]) {
            [newProfiles removeObject:p];
            break;
        }
    }
    
    [newProfiles insertObject:profile atIndex:0];  // add new profile
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:newProfiles];  // archive all profiles
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:data forKey:NXL_KEYCHAIN_PROFILES];
    
    [NXLKeyChain save:NXL_KEYCHAIN_PROFILES_SERVICE data:dict];
}

+ (void) deleteProfile:(NXLProfile*)profile {
    if (!profile) {
        return;
    }
    NSArray* profiles = [NXLCommonUtils getStoredProfiles];
    NSMutableArray* newProfiles = [NSMutableArray arrayWithArray:profiles];
    
    for (NXLProfile*p in newProfiles) {
        if ([p equalProfile:profile]) {
            [newProfiles removeObject:p];
            break;
        }
    }
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:newProfiles];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:data forKey:NXL_KEYCHAIN_PROFILES];
    
    [NXLKeyChain save:NXL_KEYCHAIN_PROFILES_SERVICE data:dict];
}


+ (NSString *) getMimeTypeByFileName:(NSString *)fileName
{
    if (fileName == nil) {
        return nil;
    }
    
    NSString *fileExtension = [fileName componentsSeparatedByString:@"."].lastObject;
    if (fileExtension == nil) {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
    CFStringRef mimeType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *mimeTypeStr = (__bridge_transfer NSString *)mimeType;
    if (mimeTypeStr == nil) {
        if([fileExtension compare:@"java" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return @"text/x-java-source";
        }
        NSString *extentensionText = @"cpp, c, h";
        NSRange foundOjb = [extentensionText rangeOfString:fileExtension options:NSCaseInsensitiveSearch];
        if (foundOjb.length > 0) {
            return @"text/plain";
        }
        return @"application/octet-stream";
    }
    return mimeTypeStr;
}

+ (NSString *) arrayToJsonString:(NSArray *)array error:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:error];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)getExtension:(NSString *)fullpath clientProfile:(NXLProfile *) userProfile error:(NSError **)error;
{
    if (fullpath == nil) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain  code:NXLSDKErrorNoSuchFile userInfo:nil];
        }
        return  nil;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullpath]) {
        if (error) {
            *error = [NSError errorWithDomain:NXLSDKErrorNXLFileDomain  code:NXLSDKErrorNoSuchFile userInfo:nil];
        }
        return nil;
    }
    if ([NXLMetaData isNxlFile:fullpath]) {
        __block NSString *fileType = @"";
        __block NSError *tempError = nil;
        dispatch_semaphore_t semi = dispatch_semaphore_create(0);
        [NXLMetaData getFileType:fullpath clientProfile:userProfile sharedInfo:nil complete:^(NSString *type, NSError *error) {
            fileType = type;
            tempError = error;
            dispatch_semaphore_signal(semi);
        }];
        dispatch_semaphore_wait(semi, DISPATCH_TIME_FOREVER);
        if (tempError && error) {
            *error = [NSError errorWithDomain:tempError.domain code:tempError.code userInfo:tempError.userInfo];
        }
        return fileType;
    } else {
        return [[fullpath pathExtension] lowercaseString];
    }
}

+(NSString *) convertToCCTimeFormat:(NSDate *) date
{
    if (date) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.sssZZ"];
        NSMutableString *timestamp = [NSMutableString stringWithString:[dateFormatter stringFromDate:date]];
        [timestamp insertString:@":" atIndex:(timestamp.length - 2)];
        return timestamp;
    }
    return nil;
}



// need to add more file type
+ (BOOL) is3DFileWithMimeType:(NSString*)mimeType
{
    if(mimeType == nil)
    {
        return NO;
    }
    if([mimeType isEqualToString:FILETYPE_HSF] )
    {
        return YES;
    }
    return NO;
}



+ (float) iosVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];;
}

+ (BOOL) isiPad
{
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad);
}

+ (NSString *) deviceID
{
    NSString *deviceID = (NSString *)[NXLKeyChain load:NXL_KEYCHAIN_DEVICE_ID];
    if (deviceID == nil) {
        deviceID = [[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [NXLKeyChain save:NXL_KEYCHAIN_DEVICE_ID data:deviceID];
    }
   
    return deviceID;
}

+ (NSNumber*) getPlatformId
{
    long idStart = 0;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        idStart = 600;
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        idStart = 700;
    }
    else
    {
        idStart = 600;
    }
    
    long plus = 0;
    NSString* v = [UIDevice currentDevice].systemVersion;
    NSString *mainVersionStr = [v componentsSeparatedByString:@"."].firstObject;
    if (mainVersionStr) {
        NSInteger mainVersionNum = mainVersionStr.integerValue;
        if (mainVersionNum != 0) {
            NSInteger baseNum = 4;
            plus = mainVersionNum - baseNum;
        }
    }
    
    return [NSNumber numberWithLong:(idStart + plus)];
}


+ (void)showAlertViewInViewController:(UIViewController*)vc title:(NSString*)title message:(NSString*)message
{
    
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"UI_BOX_OK", NULL)
                                                               style:UIAlertActionStyleCancel handler:nil];
        
        [alertController addAction:cancelAction];
        
        [vc presentViewController:alertController animated:YES completion:nil];
   
}

+ (CGRect) getScreenBounds
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    
    if (([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenBounds.size = CGSizeMake(screenBounds.size.height, screenBounds.size.width);
    }
    return screenBounds;
}


+ (NSDictionary*) parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableArray *info = [NSMutableArray arrayWithArray:pairs];
    [info removeObjectAtIndex:0];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in info) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1] stringByRemovingPercentEncoding];
        
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

+ (NSString*) randomStringwithLength:(NSUInteger)length
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123467890";
    NSMutableString *randomStr = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < length; ++i) {
        u_int32_t r = arc4random() % alphabet.length;
        unichar c = [alphabet characterAtIndex:r];
        [randomStr appendFormat:@"%C",c];
    }
    return [NSString stringWithString:randomStr];
}

+ (NSString *) getTempNXLFilePath:(NSString *) fileName
{
    NSString *tempFilePath = nil;
    if (fileName) {
        tempFilePath  = [self getNXLTempFolderPath];
        tempFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        tempFilePath = [tempFilePath stringByAppendingString:NXLFILEEXTENSION];
    }
    return tempFilePath;
}

+ (NSString *) getTempDecryptFilePath:(NSString *) srcPath clientProfile:(NXLProfile *) userProfile error:(NSError **) error
{
    NSString *tempFilePath = nil;
    if (srcPath) {
        tempFilePath = [self getNXLTempFolderPath];
        tempFilePath = [tempFilePath stringByAppendingPathComponent:[srcPath lastPathComponent]];
        NSError *error = nil;
        NSString *fileExt = [self getExtension:srcPath clientProfile:userProfile error:&error];
        if (error == nil) {
            tempFilePath = [tempFilePath stringByAppendingPathExtension:fileExt];
        }
    }
    return tempFilePath;
}

+ (NSString*) getNXLTempFolderPath
{
    NSString *path = [NSTemporaryDirectory()stringByAppendingPathComponent:@"nxSDKTmp"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // folder is not exist,so create a new folder
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

/**
 *  clean temp file,like the file after encrypt and convert for 3D files
 */
+ (void)cleanNXLTempFolder
{
    NSString *tmppath = [NXLCommonUtils getNXLTempFolderPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:tmppath error:nil];
    for(NSString* file in files)
    {
        [fileManager removeItemAtPath:[tmppath stringByAppendingPathComponent:file] error:nil];
    }
}


+ (NSString*) md5Data:(NSData *)data
{    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( data.bytes, (int)data.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *) getRmServer
{
    NSString *rmserver = [[NSUserDefaults standardUserDefaults] stringForKey:@"rmserver"];
    return rmserver;
}

+ (void) saveRmserver:(NSString *)rmserver
{
    [[NSUserDefaults standardUserDefaults] setObject:rmserver forKey:@"rmserver"];
}

+ (BOOL) isFirstTimeLaunching
{
    NSString *prevStartupVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"prevStartupVersion"];
    if (prevStartupVersion) {
        NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        if (![prevStartupVersion isEqualToString:currentVersion]) {
            return YES;
        }
    } else {
        return YES;
    }
    return NO;
}

+ (void) saveFirstTimeLaunchSymbol
{
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"prevStartupVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//+(NSString *)getImagebyExtension:(NSString *)fullPath {
//    NSString *markExtension = [NSString stringWithFormat:@".%@.", [fullPath pathExtension]];
//
//    NSString *wordString = @".docx.docm.doc.dotx.dotm.dot.";
//    NSString *pptString = @".pptx.pptm.ppt.potx.potm.pot.ppsx.ppsm.pps.ppam.ppa.";
//    NSString *excelString = @".xlsx.xlsb.xls.xltx.xltm.xlt.xlam.";
//
//    if ([markExtension compare:@".pdf." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        return @"FilePDFIcon";
//    }
//    if ([markExtension compare:@".nxl." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        return @"FileNXLIcon";
//    }
//    if ([markExtension compare:@".txt." options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        return @"FileTXTIcon";
//    }
//    
//    NSRange foundOjb = [wordString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
//    if (foundOjb.length > 0) {
//        return @"FileMSWordIcon";
//    }
//    foundOjb = [pptString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
//    if (foundOjb.length > 0) {
//        return @"FileMSPPTIcon";
//    }
//    foundOjb = [excelString rangeOfString:markExtension options:NSCaseInsensitiveSearch];
//    if (foundOjb.length > 0) {
//        return @"FileMSExcelIcon";
//    }
//    return @"Document";
//}

+ (void)setLocalFileLastModifiedDate:(NSString *)localFilePath date:(NSDate *)date {
    NSError *error;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [defaultManager attributesOfItemAtPath:localFilePath error:&error];
    if (error) {
        NSLog(@"get file attribute failed, error message: %@", error.localizedDescription);
        return;
    }
    NSMutableDictionary *fileMutableDictory = [NSMutableDictionary dictionaryWithDictionary:fileAttributes];
    if (date) {
        [fileMutableDictory setObject:date forKey:@"NSFileModificationDate"];
        [defaultManager setAttributes:fileMutableDictory ofItemAtPath:localFilePath error:&error];
    } else { 
        NSLog(@"file modified time is null");
        return;
    }

    if(error) {
        NSLog(@"modify last modify date failed,error message :%@", error.localizedDescription);
    }
}

+ (NSDate *)getLocalFileLastModifiedDate:(NSString *)localFilePath {
    NSError *error;
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [defaultManager attributesOfItemAtPath:localFilePath error:&error];
    if (error) {
        NSLog(@"get file attribute failed, error message: %@", error.localizedDescription);
        return nil;
    }
    NSDate *lastModifiedTime = [fileAttributes objectForKey:@"NSFileModificationDate"];
    return lastModifiedTime;
}

+ (UIUserInterfaceIdiom) getUserInterfaceIdiom
{
//    return [[UIDevice currentDevice] userInterfaceIdiom];
    return UIUserInterfaceIdiomPad;
}

+ (NSUInteger) getLogIndex
{
    NSUInteger retVal = arc4random();
    return retVal;
}


+ (NSString *) ISO8601Format:(NSDate *)date {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"<\"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'\""];
    return [formatter stringFromDate:date];
}

// convert URI string to normal string.
+ (NSString *)decodedURLString:(NSString *)encodedString
{
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapes(NULL, (__bridge CFStringRef)encodedString, CFSTR(""));
    return decodedString;
}

+ (NSNumber *)converttoNumber:(NSString *)string
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *number = [f numberFromString:string];
    return number;
}

+ (BOOL)ispdfFileContain3DModelFormat:(NSString *)pdfFilePath
{
    CFURLRef pdfURL = CFURLCreateWithFileSystemPath(NULL, (__bridge CFStringRef)pdfFilePath, kCFURLPOSIXPathStyle, NO);
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL(pdfURL);
    
    size_t pages = CGPDFDocumentGetNumberOfPages(document);
    //3D pdf file format: https://www.convertcadfiles.com/3d-pdf/
    for (int i = 0; i < pages; i++) {
        
        CGPDFPageRef page = CGPDFDocumentGetPage(document, i + 1);
        CGPDFDictionaryRef dic = CGPDFPageGetDictionary(page);
        CGPDFObjectRef object;
        if (CGPDFDictionaryGetObject(dic, [@"Annots" UTF8String],&object) && CGPDFObjectGetType(object) == kCGPDFObjectTypeArray) {
              CGPDFArrayRef array;
              CGPDFDictionaryGetArray(dic, [@"Annots" UTF8String], &array);
              for (int j = 0; j < CGPDFArrayGetCount(array); j++) {
                  CGPDFObjectRef object;
                  if (CGPDFArrayGetObject(array, j, &object) && CGPDFObjectGetType(object) == kCGPDFObjectTypeDictionary) {
                      const char *type;
                      CGPDFDictionaryRef anno;
                      if (CGPDFArrayGetDictionary(array, j, &anno) && CGPDFDictionaryGetName(anno, [@"Subtype" UTF8String], &type)) {
                          if ([[NSString stringWithUTF8String:type] isEqualToString:@"3D"]) {
                              CGPDFStreamRef stream;
                              if (CGPDFDictionaryGetStream(anno, [@"3DD" UTF8String], &stream)) {
                                  CGPDFDictionaryRef streamDic = CGPDFStreamGetDictionary(stream);
                                  const char *typeName;
                                  CGPDFDictionaryGetName(streamDic, [@"Type" UTF8String], &typeName);
                                  const char *subTypename;
                                  CGPDFDictionaryGetName(streamDic, [@"Subtype" UTF8String], &subTypename);
                                  if ([[NSString stringWithUTF8String:subTypename] compare:@"U3D" options:NSCaseInsensitiveSearch] == NSOrderedSame||
                                      [[NSString stringWithUTF8String:subTypename] compare:@"PRC" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//                                      CGPDFPageRelease(page);
                                      CFRelease(pdfURL);
                                      CGPDFDocumentRelease(document);
                                      return YES;
                                  }
                              }
                          }
                      }
                  }
              }
        }
//        CGPDFPageRelease(page);
    }
    CFRelease(pdfURL);
    CGPDFDocumentRelease(document);
    return NO;
}

+ (BOOL)isStewardUser:(NSString *)userId clientProfile:(NXLProfile *)profile {
    __block BOOL isSteward = NO;
    NSArray *memberships = profile.memberships;
    [memberships enumerateObjectsUsingBlock:^(NXLMembership *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.ID isEqualToString:userId]) {
            isSteward = YES;
        }
    }];
    return isSteward;
}

#pragma makr - Use less
+ (void)updateRMSAddress:(NSString *)address
{
    
}
+ (NSString *)getCurretnHostName {

    return  UIDevice.currentDevice.name;
}
+ (NSString *)getCurrentIpAdress {
    return [[[self alloc] init] getLocalIPAddress:YES];
}
- (NSString *)getLocalIPAddress:(BOOL)preferIPv4 {
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}
- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            NSLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}
- (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
@end
