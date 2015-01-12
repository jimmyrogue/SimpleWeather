//
//  WXCondition.m
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import "WXCondition.h"

#define MPS_TO_MPH 2.23694f

@implementation WXCondition

//创建一个静态的NSDictionary
+(NSDictionary *) imageMap {
    static NSDictionary *_imageMap = nil;
    if(!_imageMap){
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

-(NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{//模型名称：json键名称 嵌套元素为 节点.名称
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

//时间转换
+(NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+(NSValueTransformer *)sunriseJSONTransformer {
    return [self dateJSONTransformer];
}

+(NSValueTransformer *)sunsetJSONTransformer {
    return [self dateJSONTransformer];
}

//天气转换
+(NSValueTransformer *)conditionDescriptionJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str) {
        return @[str];
    }];
}

+(NSValueTransformer *)conditionJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

+(NSValueTransformer *)iconJSONTransformer {
    return [self conditionDescriptionJSONTransformer];
}

//风速转换
+(NSValueTransformer *)windSpeedJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue * MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue / MPS_TO_MPH);
    }];
}

//温度转换
+(NSValueTransformer *)temperatureJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithBlock:^(NSNumber *temp) {
        return @((temp.floatValue - 32)/1.8);
    }];
}

+(NSValueTransformer *)tempHighJSONTransformer {
    return [self temperatureJSONTransformer];
}

+(NSValueTransformer *)tempLowJSONTransformer {
    return [self temperatureJSONTransformer];
}

@end