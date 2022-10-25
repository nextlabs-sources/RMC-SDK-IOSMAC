//
//  NXRights.m
//  nxrmc
//
//  Created by Kevin on 16/6/21.
//  Copyright © 2016年 nextlabs. All rights reserved.
//

#import "NXLRights.h"

typedef void(^AddRightBlock)(NXLRights *rights);
@interface NXLRights ()
@property(nonatomic, strong) NSDictionary *dictRights;
@property(nonatomic, strong) NSDictionary *dictObligations;
@property(nonatomic, assign) long rights;
@property(nonatomic, strong) NSString *watermarkString;
@property(nonatomic, strong) NXLFileValidateDateModel *fileValidateDate;
@property(nonatomic, strong) NSDictionary *parseRightsDict;
@property(assign) long obs;
@end

@implementation NXLRights

- (id)init
{
    if (self = [super init]) {
        _rights = 0;
        _obs = 0;
        _dictRights = @{
                        [NSNumber numberWithLong:NXLRIGHTVIEW]: @"VIEW",
                        [NSNumber numberWithLong:NXLRIGHTEDIT]: @"EDIT",
                        [NSNumber numberWithLong:NXLRIGHTPRINT]: @"PRINT",
                        [NSNumber numberWithLong:NXLRIGHTCLIPBOARD]: @"CLIPBOARD",
                        [NSNumber numberWithLong:NXLRIGHTSAVEAS]: @"SAVEAS",
                        [NSNumber numberWithLong:NXLRIGHTDECRYPT]: @"DECRYPT",
                        [NSNumber numberWithLong:NXLRIGHTSCREENCAP]: @"SCREENCAP",
                        [NSNumber numberWithLong:NXLRIGHTSEND]: @"SEND",
                        [NSNumber numberWithLong:NXLRIGHTCLASSIFY]: @"CLASSIFY",
                        [NSNumber numberWithLong:NXLRIGHTSHARING]: @"SHARE",
                        [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]: @"DOWNLOAD",
                        };
        _dictObligations = @{
                             [NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]: @"WATERMARK",
                             };
        
       AddRightBlock addViewRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTVIEW value:YES];
       };
       AddRightBlock addEditRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTEDIT value:YES];
       };
       AddRightBlock addPrintRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTPRINT value:YES];
       };
       AddRightBlock addClipBoardRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTCLIPBOARD value:YES];
       };
       AddRightBlock addSaveAsRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTSAVEAS value:YES];
       };
       AddRightBlock addDecryptRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTDECRYPT value:YES];
       };
       AddRightBlock addScreenCapRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTSCREENCAP value:YES];
       };
       AddRightBlock addSendRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTSEND value:YES];
       };
       AddRightBlock addClassifyRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTCLASSIFY value:YES];
       };
       AddRightBlock addSharingRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTSHARING value:YES];
       };
       AddRightBlock addDownloadRight = ^(NXLRights *rights){
           [rights setRight:NXLRIGHTSDOWNLOAD value:YES];
       };
       
       AddRightBlock addWaterMarkRight = ^(NXLRights *rights){
           [rights setObligation:NXLOBLIGATIONWATERMARK value:YES];
       };
       
       _parseRightsDict = @{@"VIEW":addViewRight,
                            @"EDIT":addEditRight,
                            @"PRINT":addPrintRight,
                            @"CLIPBOARD":addClipBoardRight,
                            @"SAVEAS":addSaveAsRight,
                            @"DECRYPT":addDecryptRight,
                            @"SCREENCAP":addScreenCapRight,
                            @"SEND":addSendRight,
                            @"CLASSIFY":addClassifyRight,
                            @"SHARE":addSharingRight,
                            @"DOWNLOAD":addDownloadRight,
                            @"WATERMARK":addWaterMarkRight};
    }
    
    return self;
}

- (id)initWithRightsObs:(NSArray *)rights obligations:(NSArray *)obs
{
    if (self = [self init]) {
        [_dictRights enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSString* value = (NSString*)obj;
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF == %@", value];
            NSArray* temp = [rights filteredArrayUsingPredicate:predicate];
            if (temp.count > 0 ) {
                _rights |= [key longValue];
            }
        }];
        
        if (obs == nil) {
            [_dictObligations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                NSString* value = (NSString*)obj;
                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF == %@", value];
                NSArray* temp = [rights filteredArrayUsingPredicate:predicate];
                if (temp.count > 0 ) {
                    _obs |= [key longValue];
                }
            }];
        }
        else
        {
            [obs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary* ob = (NSDictionary*)obj;
                NSString* obValue = [ob objectForKey:@"name"];
                
                [_dictObligations enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obValue isEqualToString:(NSString*)obj]) {
                        _obs |= [key longValue];
                        *stop = YES;
                    }
                }];
                
                NSDictionary *value = [ob objectForKey:@"value"];
                _watermarkString = value[@"text"];
                
            }];
        }
    }
    
    return self;
}

- (BOOL)ViewRight
{
    return (_rights & NXLRIGHTVIEW) != 0 ? YES : NO;
}

- (BOOL)ClassifyRight
{
    return (_rights & NXLRIGHTCLASSIFY) != 0 ? YES : NO;
}

- (BOOL)EditRight
{
    return (_rights & NXLRIGHTEDIT) != 0 ? YES : NO;
}

- (BOOL)PrintRight
{
    return (_rights & NXLRIGHTPRINT) != 0 ? YES : NO;
}

- (BOOL)SharingRight
{
    return (_rights & NXLRIGHTSHARING) != 0 ? YES : NO;
}

- (BOOL)DownloadRight
{
    return (_rights & NXLRIGHTSDOWNLOAD) != 0 ? YES : NO;
}

- (BOOL)DecryptRight {
    return (_rights & NXLRIGHTDECRYPT) != 0 ? YES : NO;
}
- (BOOL)ScreencaptureRight {
    return (_rights & NXLRIGHTSCREENCAP) != 0 ? YES : NO;
}

- (BOOL)getRight:(NXLRIGHT)right {
    return (_rights & right) != 0 ? YES : NO;
}

- (BOOL)getObligation:(NXLOBLIGATION)ob
{
    return (_obs & ob) != 0 ? YES: NO;
}

- (void)setRight:(NXLRIGHT)right value:(BOOL)hasRight
{
    if (hasRight) {
        _rights |= right;
    } else {
        _rights &= ~(right);
    }
}

- (void)setObligation:(NXLOBLIGATION)ob value:(BOOL)hasOb
{
    if (hasOb) {
        _obs |= ob;
    }
    else
    {
        _obs &= ~(ob);
        if (ob == NXLOBLIGATIONWATERMARK) {
             _watermarkString = nil;
        }
    }
}

- (void)setRights:(long)rights
{
    _rights = rights;
}

- (void)setStringRights:(NSArray<NSString *> *)rights {
    for (NSString *right in rights) {
        AddRightBlock addRight = self.parseRightsDict[right];
        addRight(self);  // Here, 'self' is just a function param to self retain block, so won't make cycle retain
    }
}

- (void)setAllRights
{
    _rights = 0xFFFFFFFF;
}

- (void)setNoRights {
    _rights = 0x00000000;
}

- (long) getRights
{
    return _rights;
}

- (void)setPermissions:(long)permissions {
    _rights = permissions ;
    _obs = permissions;
}

- (long) getPermissions{
    return _rights | _obs;
}

- (NSArray*)getNamedRights
{
    NSMutableArray* namedRights = [NSMutableArray array];
    if (_rights & NXLRIGHTVIEW) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTVIEW]]];
    }
    if (_rights & NXLRIGHTEDIT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTEDIT]]];
    }
    if (_rights & NXLRIGHTPRINT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTPRINT]]];
    }
    if (_rights & NXLRIGHTCLIPBOARD) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTCLIPBOARD]]];
    }
    if (_rights & NXLRIGHTSAVEAS) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSAVEAS]]];
    }
    if (_rights & NXLRIGHTDECRYPT) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTDECRYPT]]];
    }
    if (_rights & NXLRIGHTSCREENCAP) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSCREENCAP]]];
    }
    if (_rights & NXLRIGHTSEND) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSEND]]];
    }
    if (_rights & NXLRIGHTCLASSIFY) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTCLASSIFY]]];
    }
    if (_rights & NXLRIGHTSHARING) {
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSHARING]]];
    }
    if (_rights & NXLRIGHTSDOWNLOAD){
        [namedRights addObject:[_dictRights objectForKey:[NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]]];
    }
    return namedRights;
}

- (NSArray*) getNamedObligations
{
    NSMutableArray* namedObligations = [NSMutableArray array];
    if (_obs & NXLOBLIGATIONWATERMARK) {
        NSDictionary* ob = @{@"name":[_dictObligations objectForKey:[NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]], @"value":@{@"text":self.watermarkString?:@""}};
        [namedObligations addObject:ob];
    }
    return namedObligations;
}


+ (NSArray *)getSupportedContentRights
{
    return @[  @{@"View":[NSNumber numberWithLong:NXLRIGHTVIEW]},
               @{@"Print":[NSNumber numberWithLong:NXLRIGHTPRINT]},
               @{@"Edit":[NSNumber numberWithLong:NXLRIGHTEDIT]},
               @{@"Save As": [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]},
               @{@"Re-share": [NSNumber numberWithLong:NXLRIGHTSHARING]},
         /*      @{@"Clipboard":[NSNumber numberWithLong:RIGHTCLIPBOARD]},
               @{@"Save As": [NSNumber numberWithLong:RIGHTSAVEAS]},
          
               @{@"Screen Capture": [NSNumber numberWithLong:RIGHTSCREENCAP]},
               @{@"Send": [NSNumber numberWithLong:RIGHTSEND]},
               @{@"Classify": [NSNumber numberWithLong:RIGHTCLASSIFY]},*/
              
             ];
}

- (NSString *)getRightsString {
    NSMutableString *rightsString = [[NSMutableString alloc] initWithString:@"["];
    NSInteger count = [self getNamedRights].count;
    for (NSInteger index = 0; index < count - 1; index++) {
        NSString *namedRight = [self getNamedRights][index];
        [rightsString appendString:namedRight];
        [rightsString appendString:@","];
    }
    [rightsString appendString:[self getNamedRights].lastObject];
    [rightsString appendString:@"]"];
    return rightsString;
}

- (NSString *)getWatermarkString {
    return _watermarkString;
}

- (void)setWatermarkString:(NSString *)watermarkString {
    _watermarkString = watermarkString;
    // set watermark string, means have watermark
    if (watermarkString == nil) {
        [self setObligation:NXLOBLIGATIONWATERMARK value:NO];
    }else {
        [self setObligation:NXLOBLIGATIONWATERMARK value:YES];
    }
}

+ (NSArray *)getSupportedCollaborationRights
{
    return @[
//              @{@"Reshare": [NSNumber numberWithLong:NXLRIGHTSHARING]},
//              @{@"Save As": [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]},
             ];
}
+ (NSArray *)getSuppotedMoreOptionsRights {
    return @[
                @{@"Screen Capture": [NSNumber numberWithLong:NXLRIGHTSCREENCAP]},
                @{@"Extract": [NSNumber numberWithLong:NXLRIGHTDECRYPT]}
            ];
}
- (void)setFileValidateDate:(NXLFileValidateDateModel *)validateDateModel {
    if (![_fileValidateDate isEqual:validateDateModel]) {
        _fileValidateDate = validateDateModel;
    }
}

- (NXLFileValidateDateModel *)getVaildateDateModel {
    return [_fileValidateDate copy];
}

+ (NSArray*) getSupportedObs
{
    return @[@{@"Watermark": [NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]}];
}

-(NSString *)description {
    NSArray* rights = [self getNamedRights];
    NSString* str = @"";
    for (NSString* r in rights) {
        str = [str stringByAppendingString:[NSString stringWithFormat:@"%@\r\n", r]];
    }
    
    return str;
}

- (id)copyWithZone:(NSZone *)zone
{
    NXLRights *newObj = [[NXLRights alloc] init];
    newObj.rights = self.rights;
    newObj.obs = self.obs;
    newObj.watermarkString = [self.watermarkString copy];
    newObj.fileValidateDate = [self.fileValidateDate copy];
    return newObj;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSNumber *nubRights = [NSNumber numberWithLong:_rights];
    NSNumber *nubObs = [NSNumber numberWithLong:_obs];
    [aCoder encodeObject:nubRights forKey:@"nubRights"];
    [aCoder encodeObject:nubObs forKey:@"nubObs"];
    [aCoder encodeObject:_watermarkString forKey:@"watermarkString"];
    [aCoder encodeObject:_fileValidateDate forKey:@"fileValidateDate"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        NSNumber *nubRights = [aDecoder decodeObjectForKey:@"nubRights"];
        _rights = nubRights.longValue;
        NSNumber *nubObs = [aDecoder decodeObjectForKey:@"nubObs"];
        _obs = nubObs.longValue;
        _watermarkString = [aDecoder decodeObjectForKey:@"watermarkString"];
        _fileValidateDate = [aDecoder decodeObjectForKey:@"fileValidateDate"];
        
        _dictObligations = @{
                                [NSNumber numberWithLong:NXLOBLIGATIONWATERMARK]: @"WATERMARK",
                            };
        
        _dictRights = @{
                        [NSNumber numberWithLong:NXLRIGHTVIEW]: @"VIEW",
                        [NSNumber numberWithLong:NXLRIGHTEDIT]: @"EDIT",
                        [NSNumber numberWithLong:NXLRIGHTPRINT]: @"PRINT",
                        [NSNumber numberWithLong:NXLRIGHTCLIPBOARD]: @"CLIPBOARD",
                        [NSNumber numberWithLong:NXLRIGHTSAVEAS]: @"SAVEAS",
                        [NSNumber numberWithLong:NXLRIGHTDECRYPT]: @"DECRYPT",
                        [NSNumber numberWithLong:NXLRIGHTSCREENCAP]: @"SCREENCAP",
                        [NSNumber numberWithLong:NXLRIGHTSEND]: @"SEND",
                        [NSNumber numberWithLong:NXLRIGHTCLASSIFY]: @"CLASSIFY",
                        [NSNumber numberWithLong:NXLRIGHTSHARING]: @"SHARE",
                        [NSNumber numberWithLong:NXLRIGHTSDOWNLOAD]: @"DOWNLOAD",
                        };
    }
    return self;
}
@end

