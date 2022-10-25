//
//  NXClientSessionStorage.m
//  nxSDK
//
//  Created by EShi on 8/31/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLClientSessionStorage.h"

#import "NXLClient.h"
#import "NXLTenant.h"

#import "NXLKeyChain.h"

#define  kClientKeyChain @"NXLKeychainKey" //we store all client into keychine, this paramter used as key-value's key.

static NXLClientSessionStorage *sharedObj = nil;

@interface NXLClientSessionStorage ()

@property(nonatomic, strong) NXLClient *client;

@end

@implementation NXLClientSessionStorage

+ (void)load
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.skydrm.rmcent.SDK.firstLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.skydrm.rmcent.SDK.firstLaunch"];
        // APP first launch, delete the older client info in storage
        [NXLKeyChain delete:kClientKeyChain];
    }
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObj = [[NXLClientSessionStorage alloc]initPrivate];
    });
    return sharedObj;
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone {
//    return [[self class] sharedInstance];
//}
//
//- (instancetype)copyWithZone:(NSZone *)zone {
//    return [[self class] sharedInstance];
//}

- (instancetype)init {
    return [[self class] sharedInstance];
}

#pragma mark

- (instancetype)initPrivate {
    if (self = [super init]) {
        [self loadClient];
    }
    return self;
}

- (void)loadClient {
    @synchronized (self.client) {
        self.client = [NXLKeyChain load:kClientKeyChain];
    }
}

- (void)storeClient {
    @synchronized (self.client) {
        [NXLKeyChain save:kClientKeyChain data:self.client];
    }
}

#pragma mark - public method

- (NXLClient *)getClient{
    @synchronized (self.client) {
        return self.client;
    }
}

- (void)storeClient:(NXLClient *)client {
    if (client == nil) {
        return;
    }
    @synchronized (self.client) {
        //if (![self.client isEqual:client]) {
            self.client = client;
       // }
    }
    
    [self storeClient];
}

- (void)delClient:(NXLClient *)client {
    if (client == nil) {
        return;
    }
    @synchronized (self.client) {
        self.client = nil;
        [NXLKeyChain delete:kClientKeyChain];
    }
}

@end
