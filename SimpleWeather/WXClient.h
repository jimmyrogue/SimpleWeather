//
//  WXClient.h
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa.h>
@import Foundation;

@interface WXClient : NSObject

-(RACSignal *)fetchJSONFromURL:(NSURL *)url;

-(RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate;

-(RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate;

-(RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate;

@end
