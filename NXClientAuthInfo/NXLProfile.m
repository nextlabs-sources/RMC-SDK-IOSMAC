//
//  Profile.m
//  nxrmc
//
//  Created by Kevin on 15/4/29.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import "NXLProfile.h"
#import <objc/runtime.h>
#define kProfileRmserver    @"ProfileCodingRmserver"

#define kProfileUsername                    @"ProfileCodingUsername"
#define kProfileUserId                      @"ProfileCodingUserId"
#define kProfileTicket                      @"ProfileCodingTicket"
#define kProfileTTL                         @"ProfileCodingTtl"
#define kProfileEmail                       @"ProfileCodingEmail"
#define kProfileIndividualMembership           @"ProfileCodingIndividualMembership"
#define kProfileTenantMembership      @"ProfileCodingTenantMembership"
#define KProfileMemberships                 @"ProfileCodingMemberships"
#define kProfileDisplayName                 @"ProfileCodingDisplayName"
#define kProfileAvatar                      @"ProfileCodingAvatar"
#define kProfileIdpType                     @"ProfileCodingIdpType"
#define kProfileRole                        @"ProfileCodingRole"
#define kProfileDefaultTenant               @"ProfileCodingDefaultTenant"
#define kProfileDefaultTenantID             @"ProfileCodingDefaultTenantID"
#define kProfileTenantPrefence              @"ProfileCodingTenantPrefence"

#define kMembershipsId                      @"MembershipsCodingId"
#define kMembershipsType                    @"MembershipsCodingType"
#define kMembershipsTenantId                @"MembershipsCodingTenantId"
#define kMembershipsProjectId               @"kMembershipsProjectId"
#define kMembershipsTokenGroupName          @"kMembershipsTokenGroupName"


#pragma mark
@implementation NXLMembership

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.ID = [aDecoder decodeObjectForKey:kMembershipsId];
        self.type = [aDecoder decodeObjectForKey:kMembershipsType];
        self.tenantId = [aDecoder decodeObjectForKey:kMembershipsTenantId];
        self.projectId = [aDecoder decodeObjectForKey:kMembershipsProjectId];
        self.tokenGroupName = [aDecoder decodeObjectForKey:kMembershipsTokenGroupName];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ID forKey:kMembershipsId];
    [aCoder encodeObject:_type forKey:kMembershipsType];
    [aCoder encodeObject:_tenantId forKey:kMembershipsTenantId];
    [aCoder encodeObject:_projectId forKey:kMembershipsProjectId];
    [aCoder encodeObject:_tokenGroupName forKey:kMembershipsTokenGroupName];
}

- (BOOL)equalMemberships:(NXLMembership *)membership {
    if ([self.ID caseInsensitiveCompare:membership.ID] == NSOrderedSame ){
        return YES;
    } else {
        return NO;
    }
}

@end
@implementation NXLTenantPrefence
- (instancetype)initWithDictionaryFromRMS:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
- (void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqualToString:@"WORKSPACE_ENABLED"]) {
        NSInteger a = [value integerValue];
        self.workspaceType = [[NSNumber alloc] initWithInteger:a];
    }else if ([key isEqualToString:@"ADHOC_ENABLED"]) {
        self.ADHOC_ENABLED = [value boolValue];
    } else{
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
#pragma mark -----> NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList([self class], &ivarCount);
    for (int i =0; i<ivarCount; i++) {
        
        Ivar var = vars[i];
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        id value = [self valueForKey:varName];
        [aCoder encodeObject:value forKey:varName];
    }
    free(vars);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int ivarCount = 0;
        Ivar *vars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i<ivarCount; i++) {
            Ivar var = vars[i];
            NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
            id value = [aDecoder decodeObjectForKey:varName];
            [self setValue:value forKey:varName];
        }
        free(vars);
    }
    return self;
}


@end

#pragma mark
@implementation NXLProfile

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.rmserver = [aDecoder decodeObjectForKey:kProfileRmserver];
        self.userName = [aDecoder decodeObjectForKey:kProfileUsername];
        self.userId = [aDecoder decodeObjectForKey:kProfileUserId];
        self.ticket = [aDecoder decodeObjectForKey:kProfileTicket];
        self.ttl = [aDecoder decodeObjectForKey:kProfileTTL];
        self.email = [aDecoder decodeObjectForKey:kProfileEmail];
        self.individualMembership = [aDecoder decodeObjectForKey:kProfileIndividualMembership];
        self.tenantMembership = [aDecoder decodeObjectForKey:kProfileTenantMembership];
        self.memberships = [aDecoder decodeObjectForKey:KProfileMemberships];
        self.displayName = [aDecoder decodeObjectForKey:kProfileDisplayName];
        self.avatar = [aDecoder decodeObjectForKey:kProfileAvatar];
        self.idpType = [aDecoder decodeObjectForKey:kProfileIdpType];
        self.role = [aDecoder decodeObjectForKey:kProfileRole];
        self.defaultTenant = [aDecoder decodeObjectForKey:kProfileDefaultTenant];
        self.defaultTenantID = [aDecoder decodeObjectForKey:kProfileDefaultTenantID];
        self.tenantPrefence = [aDecoder decodeObjectForKey:kProfileTenantPrefence];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_rmserver forKey:kProfileRmserver];
    [aCoder encodeObject:_userName forKey:kProfileUsername];
    [aCoder encodeObject:_userId forKey:kProfileUserId];
    [aCoder encodeObject:_ticket forKey:kProfileTicket];
    [aCoder encodeObject:_ttl forKey:kProfileTTL];
    [aCoder encodeObject:_email forKey:kProfileEmail];
    [aCoder encodeObject:_individualMembership forKey:kProfileIndividualMembership];
    [aCoder encodeObject:_tenantMembership forKey:kProfileTenantMembership];
    [aCoder encodeObject:_memberships forKey:KProfileMemberships];
    [aCoder encodeObject:_displayName forKey:kProfileDisplayName];
    [aCoder encodeObject:_avatar forKey:kProfileAvatar];
    [aCoder encodeObject:_idpType forKey:kProfileIdpType];
    [aCoder encodeObject:_role forKey:kProfileRole];
    [aCoder encodeObject:_defaultTenant forKey:kProfileDefaultTenant];
    [aCoder encodeObject:_defaultTenantID forKey:kProfileDefaultTenantID];
    [aCoder encodeObject:_tenantPrefence forKey:kProfileTenantPrefence];
}

- (BOOL)equalProfile:(NXLProfile *)profile {
    if ([self.userId caseInsensitiveCompare:profile.userId] == NSOrderedSame &&
        [self.individualMembership.tenantId caseInsensitiveCompare:profile.individualMembership.tenantId] == NSOrderedSame && self.idpType.longLongValue == profile.idpType.longLongValue) {
        return YES;
    } else {
        return NO;
    }
}

- (NXLMembership *)memberShipForProject:(NSNumber *)projectId {
    NXLMembership *retVal = nil;
    for (NXLMembership *memberShip in self.memberships) {
        if (memberShip.projectId.integerValue == projectId.integerValue) {
            retVal = memberShip;
            break;
        }
    }
    return retVal;
}

@end
