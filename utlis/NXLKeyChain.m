//
//  NXKeyChain.m
//  nxrmc
//
//  Created by Kevin on 15/4/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLKeyChain.h"

@implementation NXLKeyChain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            CFBridgingRelease(kSecClassGenericPassword), CFBridgingRelease(kSecClass),
            service, CFBridgingRelease(kSecAttrService),
            service, CFBridgingRelease(kSecAttrAccount),
            CFBridgingRelease(kSecAttrAccessibleAfterFirstUnlock),CFBridgingRelease(kSecAttrAccessible),
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    CFDictionaryRef cKeychainQuery = (__bridge CFDictionaryRef)keychainQuery;
    SecItemDelete(cKeychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey: CFBridgingRelease(kSecValueData)];
    //Add item to keychain with the search dictionary
    SecItemAdd(cKeychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:CFBridgingRelease(kSecReturnData)];
    [keychainQuery setObject: CFBridgingRelease(kSecMatchLimitOne) forKey: CFBridgingRelease(kSecMatchLimit)];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData: CFBridgingRelease(keyData)];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

+ (void)deleteAll {
    NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecClassInternetPassword,
                                (__bridge id)kSecClassCertificate,
                                (__bridge id)kSecClassKey,
                                (__bridge id)kSecClassIdentity];
    for (id secItemClass in secItemClasses) {
        NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
        SecItemDelete((__bridge CFDictionaryRef)spec);
    }
}

+ (void)update: (NSString *)service data: (id)data {
//    [self save:service data:data];
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:CFBridgingRelease(kSecReturnData)];
    [keychainQuery setObject: CFBridgingRelease(kSecMatchLimitOne) forKey: CFBridgingRelease(kSecMatchLimit)];
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, NULL) == noErr) {
        NSMutableDictionary *updateData = [NSMutableDictionary dictionaryWithObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:CFBridgingRelease(kSecValueData)];
        SecItemUpdate((__bridge CFDictionaryRef)keychainQuery, (__bridge CFDictionaryRef)updateData);
    }
}

@end
