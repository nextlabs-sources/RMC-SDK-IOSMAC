//
//  NXLLoger.m
//  nxSDK
//
//  Created by nextlabs on 9/7/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import "NXLLoger.h"

void NXLLog(NXLLogLevel lever, NSString *messageFormat, ...) {
    va_list args;
    va_start(args, messageFormat);
    NSString *message = nil;
    if (messageFormat) {
        message = [[NSString alloc]initWithFormat:messageFormat arguments:args];
    }
    [NXLLoger logWithLevel:lever message:message];
}

void writeLog(NSString *message) {
    NSLog(@"NXL SDK Log->file:%@,line:%d,%@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, message);
}

@implementation NXLLoger

+ (void)logWithLevel:(NXLLogLevel)level message:(NSString *)messageFormat,... {
    NSString *logLevel = nil;
    switch (level) {
        case NXLLogDebug:
        {
#ifndef DEBUG
            return;
#endif
            logLevel = @"Debug";
        }
            break;
        case NXLLogError:
        {
            logLevel = @"Error";
        }
        default:
            break;
    }
    
    va_list args;
    va_start(args, messageFormat);
    
    NSString *message = nil;
    if (messageFormat) {
        NSString *stringFormat = [NSString stringWithFormat:@"%@ %@", logLevel, messageFormat];
        message = [[NSString alloc]initWithFormat:stringFormat arguments:args];
    }
    writeLog(message);
}

@end
