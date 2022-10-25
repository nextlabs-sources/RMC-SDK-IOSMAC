//
//  NXLLoger.h
//  nxSDK
//
//  Created by nextlabs on 9/7/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, NXLLogLevel) {
    NXLLogError = 0,
    NXLLogDebug,
};

void NXLLog(NXLLogLevel lever, NSString *messageFormat, ...);

@interface NXLLoger : NSObject

+ (void)logWithLevel:(NXLLogLevel)level message:(NSString *)messageFormat,...;

@end
