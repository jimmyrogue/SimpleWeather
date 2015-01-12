//
//  WXDailyForecast.m
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import "WXDailyForecast.h"

@implementation WXDailyForecast

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    //获取wxcondition的映射 并创建它的可变副本。
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    
    //改变映射
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    
    //返回新的映射
    return paths;
}

@end
