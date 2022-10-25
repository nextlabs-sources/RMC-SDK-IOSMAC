//
//  NXLFetchActivityLogInfoDataModel.m
//  nxSDK
//
//  Created by xx-huang on 13/01/2017.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLFetchActivityLogInfoDataModel.h"

@implementation NXLFetchLogInfoParameterModel

#pragma mark -NXLFetchActivityLogInfoAPIRequest

-(instancetype) init
{
    self = [super init];
    if (self) {
        _start = 0;
        _count = 0;
        _searchField = @"";
        _searchText = @"";
        _orderBy = @"";
        _orderByReverse = @"true";
    }
    
    return self;
}

@end

#pragma mark -NXLLogRecordItem

@implementation NXLLogRecordItem

-(instancetype)initWithDictionary:(NSDictionary*)dictionary{
    self = [super init];
    if (self){
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}

@end

#pragma mark -NXLFetchLogInfoResultModel

@implementation NXLFetchLogInfoResultModel

-(instancetype) init
{
    self = [super init];
    if (self) {
        _fileName = @"";
        _totalCount = 0;
        _logRecordItemsArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}
@end
