//
//  NXLMultipartFormDataMaker.m
//  nxSDK
//
//  Created by EShi on 12/22/16.
//  Copyright © 2016 Eren. All rights reserved.
//
#import "NXLMultipartFormDataMaker.h"
#import "NXLCommonUtils.h"

@interface NXLMultipartFormDataMaker()
@property(nonatomic, strong) NSMutableData *formData;
@property(nonatomic, copy) NSString *boundary;
@end


@implementation NXLMultipartFormDataMaker
- (instancetype)init
{
    NSAssert(NO, @"use initWithBoundary to init");
    return nil;
}
- (instancetype)initWithBoundary:(NSString *)boundary
{
    self = [super init];
    if (self) {
        _boundary = boundary;
    }
    return self;
}
- (NSMutableData *)formData
{
    if (_formData == nil) {
        _formData = [[NSMutableData alloc] init];
    }
    return _formData;
}

- (void)addTextParameter:(NSString *)parameterName parameterValue:(NSString *)parameterValue
{
    [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterName] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[parameterValue dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
}
- (void)addFileParameter:(NSString *)parameterName fileName:(NSString *)fileName fileData:(NSData *)fileData
{
    [self.formData  appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData  appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", parameterName, fileName] dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *mimeType = [NXLCommonUtils getMimeTypeByFileName:fileName];
    if (mimeType) {
        [self.formData  appendData:[[NSString stringWithFormat:@"Content-Type:%@\r\n", mimeType] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.formData appendData:fileData];
    [self.formData appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
}
- (void)endFormData
{
    [self.formData appendData:[[NSString stringWithFormat:@"--%@--", self.boundary] dataUsingEncoding:NSUTF8StringEncoding]];
}
- (NSData *)getFormData
{
    return self.formData;
}
@end
