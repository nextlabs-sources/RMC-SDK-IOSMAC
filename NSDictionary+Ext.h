//
//  NSDictionary+Ext.h
//  nxSDK
//
//  Created by EShi on 12/19/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Ext)
- (NSData *)toJSONFormatData:(NSError **)error;
- (NSString *)toJSONFormatString:(NSError **)error;
@end
