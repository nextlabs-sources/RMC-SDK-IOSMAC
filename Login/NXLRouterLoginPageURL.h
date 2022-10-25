//
//  NXLRouterLoginPageURL.h
//  nxSDK
//
//  Created by helpdesk on 9/9/16.
//  Copyright © 2016年 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLSuperRESTAPI.h"

@interface NXLRouterLoginPageURL : NXLSuperRESTAPIRequest

- (instancetype)initWithRequest:(NSString*)tenant;

@end


@interface NXLRouterLoginPageURLResponse : NXLSuperRESTAPIResponse

@property(nonatomic, strong) NSString *loginPageURLstr;

@end
