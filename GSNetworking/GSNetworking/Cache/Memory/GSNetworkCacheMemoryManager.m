//
//  GSNetworkCacheMemoryManager.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkCacheMemoryManager.h"
#import "GSNetworkCacheMemoryRecord.h"
#import "GSNetworkResponse.h"

@interface GSNetworkCacheMemoryManager ()
@property (nonatomic, strong) NSCache *cache;
@end

@implementation GSNetworkCacheMemoryManager

- (void)saveCacheWithResponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)second {
    GSNetworkCacheMemoryRecord *record = [[GSNetworkCacheMemoryRecord alloc] init];
    record.date = [NSDate date];
    record.content = response.content;
    record.cacheSecond = second;
    [self.cache setObject:record forKey:response.requestParameterString];// 不是setValue:forKey:
}

- (GSNetworkResponse *)fetchCacheWithKey:(NSString *)key {
    GSNetworkResponse *response = nil;
    
    GSNetworkCacheMemoryRecord *record = [self.cache objectForKey:key];
    if (record.isExpired == NO && record.content) {// 没过期
        response = [[GSNetworkResponse alloc] initWithContent:record.content];
    }
    else {// 过期，删除记录
        [self.cache removeObjectForKey:key];
    }
    
    return response;
}

- (void)clearAllCache {
    [self.cache removeAllObjects];
}

#pragma mark - Setter & Getter

- (NSCache *)cache {
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
    }
    return _cache;
}

@end
