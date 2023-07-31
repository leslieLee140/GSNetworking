//
//  GSNetworkCacheDiskManager.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkCacheDiskManager.h"
#import "GSNetworkResponse.h"

NSString * const kContent = @"content";
NSString * const kLastUpdatedIntervalSince1970 = @"lastUpdatedIntervalSince1970";
NSString * const kCacheSecond = @"cacheSecond";

NSString * const kDiskCacheCenterCachedObjectKeyPrefix = @"kDiskCacheCenterCachedObjectKeyPrefix";

@implementation GSNetworkCacheDiskManager

- (void)saveCacheWithResponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)second {
    if (response.content) {
        NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
        record[kLastUpdatedIntervalSince1970] = @([NSDate date].timeIntervalSince1970);// 以1970年的时间为基准，不用考虑时区的问题
        record[kContent] = response.content;
        record[kCacheSecond] = @(second);
        
        NSString *actualKey = [NSString stringWithFormat:@"%@%@", kDiskCacheCenterCachedObjectKeyPrefix, response.requestParameterString];
        [[NSUserDefaults standardUserDefaults] setObject:record.copy forKey:actualKey];
    }
}

- (GSNetworkResponse *)fetchCacheWithKey:(NSString *)key {
    GSNetworkResponse *response = nil;
    NSString *actualKey = [NSString stringWithFormat:@"%@%@", kDiskCacheCenterCachedObjectKeyPrefix, key];
    NSDictionary *record = [[NSUserDefaults standardUserDefaults] objectForKey:actualKey];
    if (record) {
        NSTimeInterval second = [record[kCacheSecond] integerValue];
        // 取时间，算时间差
        NSTimeInterval intervalSince1970 = [record[kLastUpdatedIntervalSince1970] integerValue];
        NSDate* lastUpdatedDate = [NSDate dateWithTimeIntervalSince1970:intervalSince1970];
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:lastUpdatedDate];
        
        if (interval < second) {// 没过期
            response = [[GSNetworkResponse alloc] initWithContent:record[kContent]];
        }
        else {// 过期，删除记录
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:actualKey];
        }
    }
    
    return response;
}

- (void)clearAllCache {
    NSDictionary *defaultDict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    NSArray *list = [defaultDict.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", kDiskCacheCenterCachedObjectKeyPrefix]];
    
    for (NSString *key in list) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
