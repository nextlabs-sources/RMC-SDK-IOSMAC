//
//  NXLFileValidateDateModel.h
//  nxSDK
//
//  Created by Eren (Teng) Shi on 11/13/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NXLFileValidateDateModelType) { // NOTE the enmu vaule should follow RMS define
    NXLFileValidateDateModelTypeNeverExpire = 0,
    NXLFileValidateDateModelTypeRelative = 1,
    NXLFileValidateDateModelTypeAbsolute = 2,
    NXLFileValidateDateModelTypeRange = 3
};

@interface NXLFileValidateDateModel : NSObject<NSCopying, NSCoding>

@property (nonatomic,strong) NSDate *startTime;
@property (nonatomic,strong) NSDate *endTime;
@property (nonatomic,assign) NXLFileValidateDateModelType type;

@property (nonatomic,assign) NSUInteger year;
@property (nonatomic,assign) NSUInteger month;
@property (nonatomic,assign) NSUInteger week;
@property (nonatomic,assign) NSUInteger day;
- (instancetype)initWithDictionaryFromRMS:(NSDictionary *)dictionary;
- (instancetype)initWithNXFileValidateDateModelType:(NXLFileValidateDateModelType)type withStartTime:(NSDate *)startTime endTIme:(NSDate *)end;
- (instancetype)initRelativeValidateDateModelWithYear:(NSUInteger)year month:(NSUInteger)month week:(NSUInteger)week day:(NSUInteger)day;

- (NSString *)getValidateDateDescriptionString;
- (NSDictionary *)getPolicyFormatJSONDictionary;
- (NSDictionary *)getRMSRESTAPIShareFormatDictionary;
- (NSDictionary *)getRMSRESTAPIPerferenceFormatDictionary;

- (BOOL)checkInValidateDateRange:(NSDate *)nowDate;

@end
