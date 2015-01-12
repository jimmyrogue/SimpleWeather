//
//  WXCondition.h
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import "MTLModel.h"
#import <Mantle.h>


@interface WXCondition : MTLModel <MTLJSONSerializing> //此协议告诉Mantle序列化该对象如何从JSON映射到oc的属性

@property(nonatomic, strong)NSDate *date;
@property(nonatomic, strong)NSNumber *humidity;
@property(nonatomic, strong)NSNumber *temperature;
@property(nonatomic, strong)NSNumber *tempHigh;
@property(nonatomic, strong)NSNumber *tempLow;
@property(nonatomic, strong)NSString *locationName;
@property(nonatomic, strong)NSDate *sunrise;
@property(nonatomic, strong)NSDate *sunset;
@property(nonatomic, strong)NSString *conditionDescription;
@property(nonatomic, strong)NSString *condition;
@property(nonatomic, strong)NSNumber *windBearing;
@property(nonatomic, strong)NSNumber *windSpeed;
@property(nonatomic, strong)NSString *icon;

-(NSString *)imageName;

@end
