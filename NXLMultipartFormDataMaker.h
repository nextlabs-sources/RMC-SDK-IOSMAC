//
//  NXLMultipartFormDataMaker.h
//  nxSDK
//
//  Created by EShi on 12/22/16.
//  Copyright © 2016 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXLMultipartFormDataMaker : NSObject
- (instancetype)initWithBoundary:(NSString *)boundary;
- (void)addTextParameter:(NSString *)parameterName parameterValue:(NSString *)parameterValue;
- (void)addFileParameter:(NSString *)parameterName fileName:(NSString *)fileName fileData:(NSData *)fileData;
- (void)endFormData;

- (NSData *)getFormData;
@end
