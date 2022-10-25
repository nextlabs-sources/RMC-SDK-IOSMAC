//
//  Profile.h
//  nxrmc
//
//  Created by Kevin on 15/4/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXLMembership : NSObject<NSCoding>

@property(atomic, strong) NSString *ID;
@property(atomic, strong) NSNumber *type;
@property(atomic, strong) NSString *tenantId;
@property(atomic, strong) NSNumber *projectId;
@property(atomic, strong) NSString *tokenGroupName;

- (BOOL)equalMemberships:(NXLMembership *)membership;

@end
@interface NXLTenantPrefence : NSObject<NSCoding>
@property(nonatomic, strong)NSString *CLIENT_HEARTBEAT_FREQUENCY;
@property(nonatomic, assign)BOOL ADHOC_ENABLED;
@property(nonatomic, assign)NSInteger heartbeat;
@property(nonatomic, strong)NSArray *PROJECT_ADMIN;
@property(nonatomic, strong)NSString *SYSTEM_DEFAULT_PROJECT_TENANTID;
@property(nonatomic, strong)NSNumber *workspaceType;
- (instancetype)initWithDictionaryFromRMS:(NSDictionary *)dic;
@end
@interface NXLProfile : NSObject <NSCoding>

@property(atomic, strong) NSString *rmserver;
@property(atomic, strong) NSString *userId;
@property(atomic, strong) NSString *ticket;
@property(atomic, strong) NSNumber *ttl;
@property(atomic, strong) NSString *defaultTenant;
@property(atomic, strong) NSString *defaultTenantID;
@property(atomic ,strong) NXLTenantPrefence *tenantPrefence;
@property(atomic, strong) NSString *userName;
@property(atomic, strong) NSString *email;

@property(atomic, strong) NXLMembership *individualMembership; // old defautl memebership
@property(atomic, strong) NXLMembership *tenantMembership; // old systembucket membership
@property(atomic, strong) NSMutableArray *memberships;

@property(atomic, strong) NSString *avatar; //base64 str from uimage.
@property(atomic, strong) NSString *displayName;
@property(nonatomic, assign) NSNumber* idpType;

@property(nonatomic, strong) NSString *roles;
@property(nonatomic, assign) NSNumber *role;
- (BOOL)equalProfile:(NXLProfile *)profile;

- (NXLMembership *)memberShipForProject:(NSNumber *)projectId;

@end
