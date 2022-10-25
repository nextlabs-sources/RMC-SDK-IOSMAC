//
//  NXRESTAPITransferCenter.m
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import "NXLRESTAPITransferCenter.h"
#import "NXLSuperRESTAPI.h"
#import "NXLRestAPI.h"
#import "NXLSDKDef.h"
#import "NXLClient.h"
#import "NXLSDKDef.h"

static NXLRESTAPITransferCenter* singleInstance = nil;


@interface NXLRESTAPITransferCenter()<NXLRestAPIDelegate>
@property(nonatomic, strong) NSMutableDictionary *reqCompletionDic;
@property(nonatomic, strong) NSMutableDictionary *reqRESTConnObjectDic;
@property(nonatomic, strong) dispatch_queue_t transferCenterSerialQueue;
@property(nonatomic, strong) dispatch_queue_t nxRESTConObjectSerialQueue;
@property(nonatomic, strong) NSThread *workThread;
@end 
@implementation NXLRESTAPITransferCenter

+(instancetype) sharedInstance
{
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        singleInstance = [[super allocWithZone:nil] init];
    });
    
    return singleInstance;
}

-(instancetype) init
{
    self = [super init];
    if (self) {
        // use this serial queue do sync the operation to _reqCompletionDic
        _transferCenterSerialQueue = dispatch_queue_create("com.nextlabs.rightsmanagementclient.RESTAPITransferCenter.transferCenterSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}


+(instancetype) allocWithZone:(struct _NSZone *)zone
{
    return nil;
}
+(NSThread *) restWorkThread
{
    static NSThread * workThread = nil;
    static dispatch_once_t once_token;
    dispatch_once(&once_token, ^{
        workThread = [[NSThread alloc] initWithTarget:self selector:@selector(workThreadEntryPoint:) object:nil];
        [workThread start];
    });
    return workThread;
    
}
+(void) workThreadEntryPoint:(id)__unused object
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"nextlabs"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        // put one port in runloop to keep the runloop not exit
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark - SETTER/GETTER
-(NSMutableDictionary *) reqCompletionDic
{
    if (_reqCompletionDic == nil) {
        _reqCompletionDic = [[NSMutableDictionary alloc] init];
    }
    
    return _reqCompletionDic;
}

-(NSMutableDictionary *) reqRESTConnObjectDic
{
    if (_reqRESTConnObjectDic == nil) {
        _reqRESTConnObjectDic = [[NSMutableDictionary alloc] init];
    }
    return _reqRESTConnObjectDic;
}

#pragma mark - REST Request Manager
-(BOOL) registRESTRequest:(id<NXLRESTAPIScheduleProtocol>) request
{
    NSString *mapKey = ((NXLSuperRESTAPIRequest *)request).reqFlag;
    __block BOOL ret = YES;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        if ([[self.reqCompletionDic allKeys] containsObject:mapKey]) {
            ret = NO;
        }
        if (ret) {
            [self.reqCompletionDic setObject:request forKey:mapKey];

        }
    });
    
    return ret;  // here to return ret make sure return to the same thread???????
}

-(void) unregistRESTRequest:(id<NXLRESTAPIScheduleProtocol>) request
{
    NSString *mapKey = ((NXLSuperRESTAPIRequest *)request).reqFlag;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        [self.reqCompletionDic removeObjectForKey:mapKey];
        
    });

}

- (void)cancelRequest:(id<NXLRESTAPIScheduleProtocol>)request
{
    NSString *mapKey = ((NXLSuperRESTAPIRequest *)request).reqFlag;
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        NXLRestAPI *restAPI = [self.reqRESTConnObjectDic objectForKey:mapKey];
        if (restAPI) {
            [restAPI cancel];
        }
    });
}

-(void) sendRESTRequest:(NSURLRequest *) restRequest
{
    [self performSelector:@selector(sendRequestOnWorkThread:) onThread:[[self class] restWorkThread] withObject:restRequest waitUntilDone:NO];
}

#pragma mark - Private Methods
-(void) sendRequestOnWorkThread:(NSURLRequest *) restRequest
{
    // NXRestAPI do not support multi request, so need create NXRestAPI for every request
    NXLRestAPI *restAPI = [[NXLRestAPI alloc] init];
    restAPI.delegate = self;
    NSString *reqFlag = [restRequest valueForHTTPHeaderField:RESTAPIFLAGHEAD];
    WeakObj(self);
    dispatch_sync(self.transferCenterSerialQueue, ^{
        StrongObj(self);
        [self.reqRESTConnObjectDic setObject:restAPI forKey:reqFlag];
    });
   
    [restAPI sendRESTRequest:restRequest];
}

#pragma mark - NXRestAPIDelegate
- (void) restAPIResponse:(NSURL*) url result: (NSString*)result data:(NSData *) data error: (NSError*)err
{
    // do not care this callback
}

-(void) restAPIResponse:(NSURL *)url requestFlag:(NSString *)reqFlag result:(NSString *)result error:(NSError *)err
{
    if (reqFlag) {
        WeakObj(self);
        __block id<NXLRESTAPIScheduleProtocol> restReq = nil;
        dispatch_sync(self.transferCenterSerialQueue, ^{
            StrongObj(self);
            restReq = self.reqCompletionDic[reqFlag];
        });
        
        if (restReq) {
            RequestCompletion comp = ((NXLSuperRESTAPIRequest *) restReq).completion;
            Analysis analysis = [restReq analysisReturnData];
            id response = analysis(result, err);
            // use dispathc_async to call comp, this can make the work thread do not need to
            // wait the callbacker finish comp operation.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                 comp(response, err);
            });
           
            // do not forget remove the rest request
            WeakObj(self);
            dispatch_async(self.transferCenterSerialQueue, ^{
                StrongObj(self);
                NXLRestAPI *restAPI = [self.reqRESTConnObjectDic objectForKey:reqFlag];
                if (restAPI) {
                    [restAPI cancel];
                }
                [self.reqCompletionDic removeObjectForKey:reqFlag];
                [self.reqRESTConnObjectDic removeObjectForKey:reqFlag];
            });

        }
    }
}
@end
