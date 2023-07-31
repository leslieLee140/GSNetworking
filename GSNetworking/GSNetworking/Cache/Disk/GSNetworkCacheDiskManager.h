//
//  GSNetworkCacheDiskManager.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSNetworkResponse;

NS_ASSUME_NONNULL_BEGIN

/// 磁盘缓存，数据将在手动清空或者删除App后消失。
@interface GSNetworkCacheDiskManager : NSObject

/// 缓存
- (void)saveCacheWithResponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)second;

/// 获取缓存
- (GSNetworkResponse*)fetchCacheWithKey:(NSString *)key;

/// 清空缓存
- (void)clearAllCache;

@end

NS_ASSUME_NONNULL_END
