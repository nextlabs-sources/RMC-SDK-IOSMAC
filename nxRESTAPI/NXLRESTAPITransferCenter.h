//
//  NXRESTAPITransferCenter.h
//  nxrmc
//
//  Created by EShi on 6/7/16.
//  Copyright © 2016 nextlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NXLRESTAPIScheduleProtocol.h"

@interface NXLRESTAPITransferCenter : NSObject
+(instancetype) sharedInstance;

-(BOOL) registRESTRequest:(id<NXLRESTAPIScheduleProtocol>) request;
-(void) unregistRESTRequest:(id<NXLRESTAPIScheduleProtocol>) request;
-(void) sendRESTRequest:(NSURLRequest *) restRequest;
-(void) cancelRequest:(id<NXLRESTAPIScheduleProtocol>)request;
@end
