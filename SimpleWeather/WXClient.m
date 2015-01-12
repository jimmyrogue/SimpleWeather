//
//  WXClient.m
//  SimpleWeather
//
//  Created by jimmy-liang on 15/1/9.
//  Copyright (c) 2015年 hzsc. All rights reserved.
//

#import "WXClient.h"
#import "WXDailyForecast.h"

@interface WXClient ()

@property (nonatomic, strong)NSURLSession *session;

@end
@implementation WXClient
-(id)init {
    if(self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

-(RACSignal *)fetchJSONFromURL:(NSURL *)url {
    NSLog(@"Fetching:%@",url.absoluteString);
    
    // 1 返回信号 （不会执行 直到这个信号被订阅）-fetchJSONFromURL：创建一个对象给其他方法和对象使用 （工厂模式）
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 2 创建一个nsurlsessionDataTask  从url取数据 以后添加解析
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           // TODO: 处理取回的数据
            if(!error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if(!jsonError){
                    // 1 当json数据存在并且没有错误 发送给订阅者序列化后的json数组或者字典。
                    NSLog(@"%@",json);
                    [subscriber sendNext:json];
                } else {
                    // 2 在任一情况下如果有一个错误，通知订阅者.
                    [subscriber sendError:jsonError];
                }
            } else {
                // 2
                [subscriber sendError:error];
            }
            // 3 通知订阅者请求已经完成
            [subscriber sendCompleted];
        }];
        
        // 3 一旦订阅了信号 启动网络请求
        [dataTask resume];
        
        // 4 创建并返回RACDisposable对象 处理当信号摧毁时的清理工作
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    
    }] doError:^(NSError *error) {
        //5 增加一个side effect 以记录发射的任何错误 side effect 不订阅信号 相反 他们反悔被连接到方法链的信号 只需要一个side effect 来记录错误
        NSLog(@"%@",error);
    }];
    
}

- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate {
    // 1 使用CLLocationcoordinate2D 对象的经纬度数据来格式化url
    NSLog(@"%f========%f",coordinate.latitude,coordinate.longitude);
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 2 使用刚才的创建信号的方法
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // 3 使用MTLJSONAdapter来转换json到wxcondition 对象（模型） 使用MTLJSONSerializing协议创建的wxcondition
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
    
}

-(RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 1 再次使用fetching方法 映射json
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        //2 使用json 的 list key创建racsequence ，可以对列表进行reactivecocoa操作
        RACSequence *list = [json[@"list"] rac_sequence];
        
        //3 映射新的对象列表 调用map方法 针对列表中的每个对象 返回新的对象列表
        return [[list map:^(NSDictionary *item) {
            
            //4 再次使用MTLJSONAdapter来转换json到wxcondition对象
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            
            // 5 使用 -map方法 反悔另一个racsequence 用这个简单方法来获得一个nsarray数据
        }] array];
    }];
}

- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
    return [[self fetchJSONFromURL:url] map:^(NSDictionary *json) {
        // Build a sequence from the list of raw JSON
        RACSequence *list = [json[@"list"] rac_sequence];
        
        // Use a function to map results from JSON to Mantle objects
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}















@end
