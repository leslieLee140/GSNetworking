//
//  GSNetworkCacheManager.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSNetworkResponse.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络数据缓存类
@interface GSNetworkCacheManager : NSObject

+ (instancetype)sharedInstance;

/// 缓存到内存
- (void)saveMemoryCacheWithReponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)cacheSecond;

/// 获取内存缓存
- (GSNetworkResponse*)fetchMemoryCacheWithKey:(NSString *)key;

/// 清空内存缓存
- (void)clearAllMemoryCache;


/// 缓存到磁盘
- (void)saveDiskCacheWithReponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)cacheSecond;

/// 获取磁盘缓存
- (GSNetworkResponse*)fetchDiskCacheWithKey:(NSString *)key;

/// 清空磁盘缓存
- (void)clearAllDiskCache;

@end

NS_ASSUME_NONNULL_END
