//
//  NXTokenManager.m
//  nxrmc
//
//  Created by nextlabs on 6/22/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLTokenManager.h"

#import "NXLKeyChain.h"

#import "NXLSDKDef.h"
#import "NXLEncryptToken.h"
#import "NXLMemshipAPI.h"
#import "NXLOpenSSL.h"
#import "NSString+Codec.h"
#import "NXLProfile.h"
#import "NXLSDKDef.h"
#import "NXLCommonUtils.h"
#import "NXLClient.h"
#import "NXLRetrieveDecryptTokenAPI.h"


#define kCacheMinCount 1

#define kEncrypKeyChainKey (@"EncryptTokens")


NXLTokenManager *nxlSharedInstance = nil;

NSLock* nxlKeyChainLock = nil;
NSLock* nxlTokenLock = nil;
@interface NXLDecryptionTokenCache : NSObject

@property (nonatomic, strong) NSString* DUID;
@property (nonatomic, strong) NSString* agreement;
@property (nonatomic, strong) NSString* ml;
@property (nonatomic, strong) NSString* owner;
@property (nonatomic, strong) NSString* aeshexkey;

@end

@implementation NXLDecryptionTokenCache



- (id) initWith: (NSString*) duid agreement: (NSString*)agreement ml:(NSString*)ml owner:(NSString*)owner aeshexkey: (NSString*)aeshexkey
{
    if (self = [super init]) {
        self.DUID = duid;
        self.agreement = agreement;
        self.ml = ml;
        self.owner = owner;
        self.aeshexkey = aeshexkey;
    }
    return self;
}

- (BOOL) isEqual: (id)obj
{
    if ([obj isKindOfClass:[NXLDecryptionTokenCache class]]) {
        if ([self.DUID isEqualToString:((NXLDecryptionTokenCache *)obj).DUID] && [self.agreement isEqualToString:((NXLDecryptionTokenCache *)obj).agreement] && [self.ml isEqualToString:((NXLDecryptionTokenCache *)obj).ml] && [self.owner isEqualToString:((NXLDecryptionTokenCache *)obj).owner])
        {
            return YES;
        }
    }
    
    return NO;
}


@end

@interface NXLTokenManager ()
@property(nonatomic, strong) NXLDecryptionTokenCache *tokenCache;
@end

@implementation NXLTokenManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        nxlSharedInstance = [[self alloc] init];
    });
    
    return nxlSharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self commitInit];
        
    }
    return self;
}

- (void)commitInit {
    nxlKeyChainLock = [[NSLock alloc] init];
    nxlTokenLock = [[NSLock alloc] init];
}

-(void) cleanUserCacheData
{
    self.tokenCache = nil;
}

#pragma mark

- (NSDictionary *)getEncryptionTokenWithClientProfile:(NXLProfile *) clientProfile membershipId:(NSString *)membershipId error:(NSError**)err {
    // step1. try to get token from cache keychain
    [nxlTokenLock lock];
    membershipId = membershipId?:clientProfile.individualMembership.ID;
    NSMutableDictionary *tokens = [[NSMutableDictionary alloc]initWithDictionary:[self getEncryptTokensFromKeyChainWithMembershipId:membershipId]];
    // step2. if can not get token from keychain, generate new tokens from RMS
    if (tokens == nil || ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count == 0)
    {
        tokens = [NSMutableDictionary dictionaryWithDictionary:[self getEncryptionTokensFromServerWithClientProfile:clientProfile membershipId:membershipId error:err]];
    }
    //if both server and keychain is nil. return false.
    if (tokens == nil || ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count == 0) {
        return nil;
    }
    
    //it cache is less than min count. get more tokens and cache them
    if (tokens && ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count < kCacheMinCount + 1) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError* error = nil;
            [self getEncryptionTokensFromServerWithClientProfile:clientProfile membershipId:membershipId error:&error];
        });
    }
    
    if (tokens && ((NSDictionary *)tokens[TOKEN_TOKENS_PAIR_KEY]).count) {
        NSMutableDictionary *tokensPair = [[NSMutableDictionary alloc]initWithDictionary:tokens[TOKEN_TOKENS_PAIR_KEY]];
        NSString *key = [[tokensPair allKeys] objectAtIndex:0];  // just get first token pair
        
        NSDictionary *token = @{key: [tokensPair objectForKey:key]};
        // when using a token, remove it.
        [tokensPair removeObjectForKey:key];
        tokens[TOKEN_TOKENS_PAIR_KEY] = tokensPair;
        // update keychain
        [self saveEncryptTokensToKeyChainWithMembershipId:membershipId tokens:tokens];
        
        NSDictionary *retToken = @{TOKEN_AG_KEY:tokens[TOKEN_AG_KEY], TOKEN_AG_ICA: tokens[TOKEN_AG_ICA], TOKEN_ML_KEY:tokens[TOKEN_ML_KEY], TOKEN_TOKENS_PAIR_KEY:token};
        [nxlTokenLock unlock];
        return retToken;
    }
    
    return nil;
}

- (NSString *)getCentralPolicyFileDecryptionTokenWithDUID:(NSString *)duid agreement:(NSData *)pubKey owner:(NSString *)owner ml:(NSString *)ml profile:(NXLProfile *)userProfile fileTags:(NSString *)fileTags sharedInfo:(NSDictionary *)sharedInfo error:(NSError *__autoreleasing *)err {
    NSString *agreement = [NXLOpenSSL DHAgreementFromBinary:pubKey];
    NSString *token = [self retrieveDecryptTokenFromServerWithDUID:duid agreement:agreement owner:owner ml:ml profile:userProfile filePolicy:nil fileTags:fileTags protectionType:1 sharedInfo:sharedInfo error:err];
    return token;
}

- (NSString *)getAdhocFileDecryptionTokenWithDUID:(NSString *)duid agreement:(NSData *)pubKey owner:(NSString *)owner ml:(NSString *)ml profile:(NXLProfile *)userProfile filePolicy:(NSString *)filePolcy sharedInfo:(NSDictionary *)sharedInfo error:(NSError *__autoreleasing *)err {
    NSString *agreement = [NXLOpenSSL DHAgreementFromBinary:pubKey];
    NSString *token = [self retrieveDecryptTokenFromServerWithDUID:duid agreement:agreement owner:owner ml:ml profile:userProfile filePolicy:filePolcy fileTags:nil protectionType:0 sharedInfo:sharedInfo error:err];
    return token;
}

#pragma mark -

- (NSDictionary *)getEncryptionTokensFromServerWithClientProfile:(NXLProfile *)clientProfile  membershipId:(NSString *)membershipId error:(NSError**)err{
    
    __block NSDictionary *certificates = nil;
    
    // call membership first
    NXLMemshipAPIRequestModel *model = [[NXLMemshipAPIRequestModel alloc] initWithClientProfile:clientProfile publicKey:[NXLOpenSSL generateDHKeyPair][DH_PUBLIC_KEY] memberShipId:membershipId];
    
    NXLMemshipAPI *memshipAPI = [[NXLMemshipAPI alloc]initWithRequest:model];
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSError* apiError = nil;
    [memshipAPI requestWithObject:nil Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            apiError = error;
            NSLog(@"error %@", error.localizedDescription);
            
        } else {
            NXLMemshipAPIResponse *membershipResponse = (NXLMemshipAPIResponse *)response;
            if (membershipResponse.rmsStatuCode != 200) {
                NSLog(@"error %@", membershipResponse.rmsStatuMessage);

                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:membershipResponse.rmsStatuCode userInfo:nil];
                
            } else {
                certificates = membershipResponse.results;
            }
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    if (apiError) {
        if (err) {
            *err = apiError;
        }
        
        return nil;
    }
    
    if (certificates == nil || certificates.count < 2) {
        if (err) {
            *err = [NSError errorWithDomain:NXLSDKErrorRestDomain code:NXLSDKErrorFailedRequestMembership userInfo:nil];
        }
        return nil;
    }
    
    NSString* rootCA = nil;
    if (certificates.count >= 3) {
        rootCA = [certificates objectForKey:@"certficate3"];
    }
    else
    {
        rootCA = [certificates objectForKey:@"certficate2"];
    }
    
    NSString *tokenAgreement = nil;
    NSData* binPubKey = nil;
    [NXLOpenSSL DHAgreementPublicKey:rootCA binPublicKey:&binPubKey agreement:&tokenAgreement];
    
    // calculate agreement between member private key and iCA public key
    NSString* iCA = [certificates objectForKey:@"certficate2"];
    NSData* agreementICA = nil;
    NSString* sAgreementICA = nil;
    [NXLOpenSSL DHAgreementPublicKey:iCA binPublicKey:&agreementICA agreement:&sAgreementICA];
    
    // Generate "create encryption token" request
    NXLEncryptTokenAPIRequestModel *encryptmodel = [[NXLEncryptTokenAPIRequestModel alloc] initWithUserId:clientProfile.userId ticket:clientProfile.ticket membership:membershipId agreement:tokenAgreement];
    
    dispatch_semaphore_t sema2 = dispatch_semaphore_create(0);
    NXLEncryptTokenAPI *encryptAPI = [[NXLEncryptTokenAPI alloc]initWithRequest:encryptmodel];
    apiError = nil;
    __block NSDictionary *tokens = nil;
    [encryptAPI requestWithObject:nil Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            apiError = error;
            NSLog(@"encryptTokenAPI Requset model error");
        } else {
            NXLEncryptTokenAPIResponse *encryptResponse = (NXLEncryptTokenAPIResponse *)response;
            if (encryptResponse.rmsStatuCode != 200) {
                NSLog(@"error %@", encryptResponse.rmsStatuMessage);

                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:encryptResponse.rmsStatuCode userInfo:nil];
            } else {
                
                tokens = @{TOKEN_AG_KEY:binPubKey, TOKEN_AG_ICA: agreementICA, TOKEN_ML_KEY:encryptResponse.ml, TOKEN_TOKENS_PAIR_KEY:encryptResponse.tokens};
               [self saveEncryptTokensToKeyChainWithMembershipId:membershipId tokens:tokens];
               
            }
        }
        dispatch_semaphore_signal(sema2);
    }];
    dispatch_semaphore_wait(sema2, DISPATCH_TIME_FOREVER);
    
    if (err) {
        *err = apiError;
    }
    
    return tokens;
}

- (NSString *)retrieveDecryptTokenFromServerWithDUID:(NSString *)duid agreement: (NSString*)agreement owner:(NSString *)owner ml:(NSString *)ml profile:(NXLProfile *) userProfile filePolicy:(NSString *)filePolicy fileTags:(NSString *)fileTags protectionType:(NSUInteger)protectionType sharedInfo:(NSDictionary *)sharedInfoDict error: (NSError**)err {
    // Because memeber ship always in format mId@token_group_name, so we can get token_group_name by separate string
    NSArray *ownerInfoArray = [owner componentsSeparatedByString:@"@"];
    NSString *tokenGroupName = ownerInfoArray.lastObject;
    NXLRetrieveDecryptTokenModel *retrieveTokenModel = [[NXLRetrieveDecryptTokenModel alloc] initWithUserId:userProfile.userId ticket:userProfile.ticket tokenGroup:tokenGroupName owner:owner agreement:agreement duid:duid protectionType:protectionType filePolicy:filePolicy fileTags:fileTags ml:ml sharedInfo:sharedInfoDict];
    __block NSString *token = nil;
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    __block NSError* apiError = nil;
    [[NXLRetrieveDecryptTokenRequest alloc] requestWithObject:retrieveTokenModel Completion:^(NXLSuperRESTAPIResponse *response, NSError *error) {
        if (error) {
            apiError = error;
            
            
        } else {
            NXLRetrieveDecryptTokenResponse *decryptResponse = (NXLRetrieveDecryptTokenResponse *)response;
            if (decryptResponse.rmsStatuCode != 200) {
                NSDictionary *userInfoDict = @{NSLocalizedDescriptionKey:decryptResponse.rmsStatuMessage};
                apiError = [NSError errorWithDomain:NXLSDKErrorRestDomain code:decryptResponse.rmsStatuCode userInfo:userInfoDict];
            }
            else
            {
                token = decryptResponse.decryptToken;
                //   NSLog(@"get token from server: %@", token);
            }
        }
        dispatch_semaphore_signal(sema);
    }];
    // wait for api access to finish
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    if (err) {
        *err = apiError;
    }
    return token;
}

#pragma mark

- (NSDictionary *)getEncryptTokensFromKeyChainWithMembershipId:(NSString *)membershipId {
    [nxlKeyChainLock lock];
    NSMutableDictionary *tenantToken = [NXLKeyChain load:kEncrypKeyChainKey];
    NSString *tokenKey = [NSString stringWithFormat:@"%@_%@_%@", [NXLClient currentNXLClient:nil].userTenant.tenantID, [NXLClient currentNXLClient:nil].userID, membershipId];
    if (tenantToken) {
        // this means user have change the tenant, so we need delete the old tenant encrypt token
        if (!tenantToken[tokenKey]) {
            [NXLKeyChain delete:kEncrypKeyChainKey];
            tenantToken = nil;
        }
    }
    [nxlKeyChainLock unlock];
    if(tenantToken){
         return tenantToken[tokenKey];
    }else{
        return nil;
    }
   
}

- (void)saveEncryptTokensToKeyChainWithMembershipId:(NSString *)membershipId tokens:(NSDictionary *)tokens {
    [nxlKeyChainLock lock];
    NSMutableDictionary *oldTokens = [NXLKeyChain load:kEncrypKeyChainKey];
    if (oldTokens) {
        [NXLKeyChain delete:kEncrypKeyChainKey];
    }
    NSString *tokenKey = [NSString stringWithFormat:@"%@_%@_%@", [NXLClient currentNXLClient:nil].userTenant.tenantID, [NXLClient currentNXLClient:nil].userID, membershipId];
    NSDictionary *tenantToken = @{tokenKey:tokens};
    [NXLKeyChain save:kEncrypKeyChainKey data:tenantToken];
    
    [nxlKeyChainLock unlock];
}

- (void)deleteEncryptTokensInkeyChain {
    [nxlKeyChainLock lock];
    [NXLKeyChain delete:kEncrypKeyChainKey];
    [nxlKeyChainLock unlock];
}


@end
