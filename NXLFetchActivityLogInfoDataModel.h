//
//  NXLFetchActivityLogInfoDataModel.h
//  nxrmc
//
//  Created by xx-huang on 13/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NXLFetchLogInfoParameterModel : NSObject

@property(nonatomic, strong) NSString *searchField;
@property(nonatomic, strong) NSString *searchText;
@property(nonatomic, strong) NSString *orderBy;
@property(nonatomic, strong) NSString *orderByReverse;
@property(nonatomic, assign) NSUInteger start;
@property(nonatomic, assign) NSUInteger count;

@end

@interface NXLLogRecordItem : NSObject

@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *operation;
@property(nonatomic, strong) NSString *deviceType;
@property(nonatomic, strong) NSString *deviceId;
@property(nonatomic, strong) NSString *accessTime;
@property(nonatomic, strong) NSString *accessResult;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface NXLFetchLogInfoResultModel : NSObject

@property(nonatomic, strong) NSString *fileName;
@property(nonatomic, strong) NSMutableArray *logRecordItemsArray;
@property(nonatomic, assign) NSUInteger totalCount;

@end

