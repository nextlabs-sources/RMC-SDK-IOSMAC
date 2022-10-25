//
//  NXRestAPI.h
//  nxrmc
//
//  Created by Kevin on 15/6/24.
//  Copyright (c) 2015年 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NXLLoginUser;
@protocol NXLURLConnectionDelegate <NSObject>

@required
-(void) postResponse: (NSURL*) url result: (NSString*)result data:(NSData *) data error: (NSError*)err;
@optional
-(void) postResponse:(NSURL *)url requestFlag:(NSString *) reqFlag result:(NSString *)result error:(NSError *)err;

@end
@interface NXLURLConnection : NSObject

//- (void) sendGetRequest: (NSURL*)url cert: (NSString *)cert;
//- (void) sendPostRequest: (NSURL*)url cert: (NSString*)cert postData: (NSData*)postData;
//- (void) sendPostRequest: (NSURL *)url cert:(NSString*)cert postData:(NSData *)postData contentType:(NSString *)type;
- (void) sendRequest:(NSURLRequest *) request;
- (void) cancel;

@property (nonatomic, weak) id<NXLURLConnectionDelegate> delegate;


@end

@interface NXLRESTAPIVersion : NSObject

@property (nonatomic, assign) int major;
@property (nonatomic, assign) int minor;
@property (nonatomic, assign) int maintenance;
@property (nonatomic, assign) int patch;
@property (nonatomic, assign) int build;

@end

@protocol NXLRestAPIDelegate <NSObject>

@required
- (void) restAPIResponse:(NSURL*) url result: (NSString*)result data:(NSData *) data error: (NSError*)err;
@optional
- (void) restAPIResponse:(NSURL *)url progress:(NSNumber *)progress;
- (void) restAPIResponse:(NSURL *)url requestFlag:(NSString *) reqFlag result:(NSString *)result error:(NSError *)err;

@end
@interface NXLRestAPI : NSObject <NXLURLConnectionDelegate>

+ (NXLRESTAPIVersion*) versionMake: (int) major minor: (int)minor maintenance: (int)maintenance patch: (int) patch build: (int)build;




- (void) sendRESTRequest:(NSURLRequest *) restRequest;

- (void) cancel;

// new Restful API
- (void) getEncryptionTokens;

@property(nonatomic, weak) id<NXLRestAPIDelegate> delegate;
@property (nonatomic) NSInteger increateId;
@end
