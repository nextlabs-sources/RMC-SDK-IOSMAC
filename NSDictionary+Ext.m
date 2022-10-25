//
//  NSDictionary+Ext.m
//  nxSDK
//
//  Created by EShi on 12/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NSDictionary+Ext.h"

@implementation NSDictionary (Ext)
- (NSData *)toJSONFormatData:(NSError **)error
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:error];
    return data;
}

- (NSString *)toJSONFormatString:(NSError **)error
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:error];
    if (!jsonData) {
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
