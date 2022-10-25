//
//  NXLFileValidateDateModel.m
//  nxSDK
//
//  Created by Eren (Teng) Shi on 11/13/17.
//  Copyright © 2017 Eren. All rights reserved.
//

#import "NXLFileValidateDateModel.h"
#import <objc/runtime.h>
@interface NXLFileValidateDateModel ()

@property (nonatomic,strong) NSDateFormatter *formater;

@end

@implementation NXLFileValidateDateModel
- (instancetype)initWithNXFileValidateDateModelType:(NXLFileValidateDateModelType)type withStartTime:(NSDate *)startTime endTIme:(NSDate *)end {
    if (self = [super init]) {
        _type = type;
        _startTime = startTime;
        _endTime = end;
    }
    return self;
}
- (instancetype)initWithDictionaryFromRMS:(NSDictionary *)dictionary {
    if (self = [super init]) {
        NSNumber *expiryType = dictionary[@"option"];
        switch (expiryType.integerValue) {
            case 0: // never expire
            {
                self = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeNeverExpire withStartTime:nil endTIme:nil];
            }
                break;
            case 1: // relative expiry date
            {
                NSDictionary *relativeDay = dictionary[@"relativeDay"];
                
                NSInteger year = ((NSNumber *)relativeDay[@"year"]).integerValue;
                NSInteger month = ((NSNumber *)relativeDay[@"month"]).integerValue;
                NSInteger week = ((NSNumber *)relativeDay[@"week"]).integerValue;
                NSInteger day = ((NSNumber *)relativeDay[@"day"]).integerValue;
                
                self = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:year month:month week:week day:day];
            }
                break;
            case 2: // absolute expiry date
            {
                long long endDateSeconds = ((NSNumber *)dictionary[@"endDate"]).longLongValue / 1000;
                self = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeAbsolute withStartTime:[NSDate date] endTIme:[[NSDate alloc] initWithTimeIntervalSince1970:endDateSeconds]];
            }
                break;
            case 3: // range expirey date
            {
                long long startDateSeconds = ((NSNumber *)dictionary[@"startDate"]).longLongValue / 1000;
                long long endDateSeconds = ((NSNumber *)dictionary[@"endDate"]).longLongValue / 1000;
                self = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:NXLFileValidateDateModelTypeRange withStartTime:[[NSDate alloc] initWithTimeIntervalSince1970:startDateSeconds] endTIme:[[NSDate alloc] initWithTimeIntervalSince1970:endDateSeconds]];
            }
                break;
            default:
                break;
        }
    }
    return self;
}
- (instancetype)initRelativeValidateDateModelWithYear:(NSUInteger)year month:(NSUInteger)month week:(NSUInteger)week day:(NSUInteger)day {
    if (self = [super init]) {
        _type = NXLFileValidateDateModelTypeRelative;
        _startTime = [NSDate date];
        _startTime = [self beginOfDay:_startTime];
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *adcomps = [[NSDateComponents alloc] init];
        [adcomps setYear:year];
        [adcomps setMonth:month];
        [adcomps setDay:(day + week *7)];
        [adcomps setSecond:-1];
        _endTime = [calendar dateByAddingComponents:adcomps toDate:_startTime options:0];
        
        // to modify start of a day/end of a day
        _endTime = [self endOfDay:_endTime];
        
        _year = year;
        _month = month;
        _week = week;
        _day = day;
    }
    return self;
}

- (NSString *)getValidateDateDescriptionString
{
    NSString *des = @"";
    switch (_type) {
        case NXLFileValidateDateModelTypeNeverExpire:
            des = @"Never expire";
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        case NXLFileValidateDateModelTypeRelative:
        {
            NSString *dateStr = [self.createDateFormatter stringFromDate:_endTime];
            des = [NSString stringWithFormat:@"Until %@",dateStr];
        }
            break;
        case NXLFileValidateDateModelTypeRange:
        {
            NSString *startDate = [self.createDateFormatter stringFromDate:_startTime];
            NSString *endDate = [self.createDateFormatter stringFromDate:_endTime];
            des = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];
        }
            break;
            
        default:
            des = @"Never expire";
            break;
    }
    return des;
}

- (NSDictionary *)getPolicyFormatJSONDictionary {
    NSDictionary *retDict = nil;
    switch (_type) {
        case NXLFileValidateDateModelTypeNeverExpire:
            retDict = nil;
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        case NXLFileValidateDateModelTypeRelative:
        {
            retDict = @{@"type":@1, @"operator":@"<=", @"name":@"environment.date", @"value":@(self.endTime.timeIntervalSince1970 * 1000)};
        }
            break;
        case NXLFileValidateDateModelTypeRange:
        {
            retDict = @{@"type":@0, @"operator":@"&&", @"expressions":@[@{@"type":@1, @"operator":@">=", @"name":@"environment.date",                                  @"value":@(self.startTime.timeIntervalSince1970 * 1000)},
                                                                        @{@"type":@1, @"operator":@"<=", @"name":@"environment.date",                                  @"value":@(self.endTime.timeIntervalSince1970 * 1000)}]};
        }
            break;
        default:
            break;
    }
    return retDict;
}

- (NSDictionary *)getRMSRESTAPIShareFormatDictionary {
    NSDictionary *validateDateInfoDict = nil;
    switch (self.type) {
        case NXLFileValidateDateModelTypeNeverExpire:
        {
            validateDateInfoDict = @{@"option":@0};
        }
            break;
        case NXLFileValidateDateModelTypeRelative:
        {
            validateDateInfoDict = @{@"option":@1,
                                     @"endDate":[NSNumber numberWithLongLong:[self.endTime timeIntervalSince1970]*1000],
                                     };
        }
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        {
            validateDateInfoDict = @{@"option":@2,
                                     @"endDate":[NSNumber numberWithLongLong:[self.endTime timeIntervalSince1970]*1000],
                                     };
        }
            break;
        case NXLFileValidateDateModelTypeRange:
        {
            validateDateInfoDict = @{@"option":@3,
                                     @"startDate":[NSNumber numberWithLongLong:[self.startTime timeIntervalSince1970]*1000],
                                     @"endDate":[NSNumber numberWithLongLong:[self.endTime timeIntervalSince1970]*1000],
                                     };
        }
            break;
        default:
            break;
    }
    return validateDateInfoDict;
}

- (NSDictionary *)getRMSRESTAPIPerferenceFormatDictionary {
    NSDictionary *validateDateInfoDict = nil;
    switch (self.type) {
        case NXLFileValidateDateModelTypeNeverExpire:
        {
            validateDateInfoDict = @{@"option":@0};
        }
            break;
        case NXLFileValidateDateModelTypeRelative:
        {
            
            validateDateInfoDict = @{@"option":@1,
                                     @"relativeDay":@{
                                             @"year":[NSNumber numberWithInteger:self.year],
                                             @"month":[NSNumber numberWithInteger:self.month],
                                             @"week":[NSNumber numberWithInteger:self.week],
                                             @"day":[NSNumber numberWithInteger:self.day],
                                             }};
        }
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        {
            validateDateInfoDict = @{@"option":@2,
                                     @"endDate":[NSNumber numberWithLongLong:[self.endTime timeIntervalSince1970]*1000],
                                     };
        }
            break;
        case NXLFileValidateDateModelTypeRange:
        {
            validateDateInfoDict = @{@"option":@3,
                                     @"startDate":[NSNumber numberWithLongLong:[self.startTime timeIntervalSince1970]*1000],
                                     @"endDate":[NSNumber numberWithLongLong:[self.endTime timeIntervalSince1970]*1000],
                                     };
        }
            break;
        default:
            break;
    }
    return validateDateInfoDict;
}

- (NSDateFormatter *)createDateFormatter
{
    if (!_formater) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.timeZone = [NSTimeZone localTimeZone];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"EEEE,MMMM d,yyyy";
        self.formater = dateFormatter;
    }
    return _formater;
}

- (NSString *)description {
    return [self getValidateDateDescriptionString];
}

// copy
- (id)copyWithZone:(nullable NSZone *)zone {
    NXLFileValidateDateModel *copyModel = nil;
    if (self.type == NXLFileValidateDateModelTypeRelative) {
        copyModel = [[NXLFileValidateDateModel alloc] initRelativeValidateDateModelWithYear:self.year month:self.month week:self.week day:self.day];
    }else {
        copyModel = [[NXLFileValidateDateModel alloc] initWithNXFileValidateDateModelType:self.type withStartTime:self.startTime endTIme:self.endTime];
    }
    return copyModel;
}

- (BOOL)checkInValidateDateRange:(NSDate *)nowDate {
    switch (self.type) {
        case NXLFileValidateDateModelTypeNeverExpire:
            return YES;
            break;
        case NXLFileValidateDateModelTypeRange:
            return !([[nowDate earlierDate:self.startTime] isEqualToDate:nowDate] || [[nowDate laterDate:self.endTime] isEqualToDate:nowDate]);
            break;
        case NXLFileValidateDateModelTypeAbsolute:
        case NXLFileValidateDateModelTypeRelative:
            return !([[nowDate laterDate:self.endTime] isEqualToDate:nowDate]);
            break;
        default:
            break;
    }
}

// equal
- (NSUInteger)hash {
    return [[NSNumber numberWithInteger:self.type] hash]^
    [[NSNumber numberWithInteger:self.year] hash]^
    [[NSNumber numberWithInteger:self.month] hash]^
    [[NSNumber numberWithInteger:self.week] hash]^
    [[NSNumber numberWithInteger:self.day] hash]^
    [self.startTime hash]^
    [self.endTime hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[NXLFileValidateDateModel class]]) {
        return NO;
    }
    
    NXLFileValidateDateModel *otherModel = (NXLFileValidateDateModel *)object;
    if (otherModel.type == self.type) {
        switch (self.type) {
            case NXLFileValidateDateModelTypeNeverExpire:
            {
                return YES;
            }
                break;
            case NXLFileValidateDateModelTypeRelative:
            {
                if (otherModel.year == self.year && otherModel.month == self.month && otherModel.week == self.week && otherModel.day == self.day) {
                    return YES;
                }
            }
                break;
            case NXLFileValidateDateModelTypeAbsolute:
            {
                if ([otherModel.endTime isEqualToDate:self.endTime]) {
                    return YES;
                }
            }
                break;
            case NXLFileValidateDateModelTypeRange:
            {
                if ([otherModel.startTime isEqualToDate:self.startTime] && [otherModel.endTime isEqualToDate:self.endTime]) {
                    return YES;
                }
            }
                break;
            default:
                break;
        }
    }
    return NO;
}

-(NSDate *)endOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    [components setHour:23];
    [components setMinute:59];
    [components setSecond:59];
    
    return [cal dateFromComponents:components];
}

-(NSDate *)beginOfDay:(NSDate *)date
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    return [cal dateFromComponents:components];
}
#pragma mark -----> NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    unsigned int ivarCount = 0;
    Ivar *vars = class_copyIvarList([self class], &ivarCount);
    for (int i =0; i<ivarCount; i++) {
        
        Ivar var = vars[i];
        NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
        id value = [self valueForKey:varName];
        [aCoder encodeObject:value forKey:varName];
    }
    free(vars);
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int ivarCount = 0;
        Ivar *vars = class_copyIvarList([self class], &ivarCount);
        for (int i = 0; i<ivarCount; i++) {
            Ivar var = vars[i];
            NSString *varName = [NSString stringWithUTF8String:ivar_getName(var)];
            id value = [aDecoder decodeObjectForKey:varName];
            [self setValue:value forKey:varName];
        }
        free(vars);
    }
    return self;
}

@end
