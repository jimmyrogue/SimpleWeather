//
//  WXManager.m
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import "WXManager.h"
#import "WXClient.h"
#import <TSMessages/TSMessage.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WXManager ()

@property (nonatomic, strong, readwrite) WXCondition *currentCondition;
@property (nonatomic, strong, readwrite) CLLocation *currentLocation;
@property (nonatomic, strong, readwrite) NSArray *hourlyForecast;
@property (nonatomic, strong, readwrite) NSArray *dailyForecast;

// 2
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL isFirstUpdate;
@property (nonatomic, strong) WXClient *client;

@end

@implementation WXManager

+(instancetype)sharedManager {
    static id _shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        _shareManager = [[self alloc] init];
    });
    return _shareManager;
}

- (id)init {
    if (self = [super init]) {
        
        // 1  ????????????
        NSLog(@"init");
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        //_locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //_locationManager.distanceFilter=10;
        //[_locationManager requestAlwaysAuthorization];
        [_locationManager requestWhenInUseAuthorization];
        //[_locationManager startUpdatingLocation];

        
        // 2
        NSLog(@"client init");
        _client = [[WXClient alloc] init];
        
        // 3
        NSLog(@"观察者");
        NSLog(@"conditon:%@",_currentCondition);
        NSLog(@"location:%@",_currentLocation);
        [[[[RACObserve(self, currentLocation) ignore:nil] flattenMap:^(CLLocation *newLocation) {
            return [RACSignal merge:@[
                                      [self updateCurrentConditions],
                                      [self updateDailyForecast],
                                      [self updateHourlyForecast]
                                      ]];
        }] deliverOn:RACScheduler.mainThreadScheduler] subscribeError:^(NSError *error) {
            [TSMessage showNotificationWithTitle:@"Error" subtitle:@"problem!!!" type:TSMessageNotificationTypeError];
        }];
    }
    NSLog(@"%@",self);
    return self;
}

-(void)findCurrentLocation {
    self.isFirstUpdate = YES;
    //[self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    //1忽略第一个位置更新 基本上是缓存值
    NSLog(@"开始定位");
    if(self.isFirstUpdate) {
        self.isFirstUpdate = NO;
        return;
    }
    
    CLLocation *location = [locations lastObject];
    
    //2获取到一定精度的位置 停止进一步更新
    if(location.horizontalAccuracy > 0) {
        //3设置目前的位置值 触发init中设置的RACObservable
        self.currentLocation = location;
        [self.locationManager stopUpdatingLocation];
    }
}

- (RACSignal *)updateCurrentConditions {
    return [[self.client fetchCurrentConditionsForLocation:self.currentLocation.coordinate] doNext:^(WXCondition *condition) {
        self.currentCondition = condition;
    }];
}

- (RACSignal *)updateHourlyForecast {
    return [[self.client fetchHourlyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.hourlyForecast = conditions;
    }];
}

- (RACSignal *)updateDailyForecast {
    return [[self.client fetchDailyForecastForLocation:self.currentLocation.coordinate] doNext:^(NSArray *conditions) {
        self.dailyForecast = conditions;
    }];
}


/**
*定位失败，回调此方法
*/
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息%@",error);
    }
}







@end
