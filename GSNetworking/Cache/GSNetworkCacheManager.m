//
//  GSNetworkCacheManager.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkCacheManager.h"
#import "GSNetworkResponse.h"
#import "GSNetworkCacheMemoryManager.h"
#import "GSNetworkCacheDiskManager.h"

@interface GSNetworkCacheManager ()
@property (nonatomic, strong) GSNetworkCacheMemoryManager *memoryCacheManager;
@property (nonatomic, strong) GSNetworkCacheDiskManager   *diskCacheManager;
@end

@implementation GSNetworkCacheManager

+ (instancetype)sharedInstance {
    static GSNetworkCacheManager *cacheCenter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cacheCenter = [[GSNetworkCacheManager alloc] init];
    });
    return cacheCenter;
}

#pragma mark - Memory cache

- (void)saveMemoryCacheWithReponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)cacheSecond {
    if (response.requestParameterString && response.content) {
        [self.memoryCacheManager saveCacheWithResponse:response forSecond:cacheSecond];
    }
}

- (GSNetworkResponse *)fetchMemoryCacheWithKey:(NSString *)key {
   return [self.memoryCacheManager fetchCacheWithKey:key];
}

- (void)clearAllMemoryCache {
    [self.memoryCacheManager clearAllCache];
}

#pragma mark - Disk cache

- (void)saveDiskCacheWithReponse:(GSNetworkResponse *)response forSecond:(NSTimeInterval)cacheSecond {
    if (response.requestParameterString && response.content) {
        [self.diskCacheManager saveCacheWithResponse:response forSecond:cacheSecond];
    }
}

- (GSNetworkResponse *)fetchDiskCacheWithKey:(NSString *)key {
    return [self.diskCacheManager fetchCacheWithKey:key];
}

- (void)clearAllDiskCache {
    [self.diskCacheManager clearAllCache];
}

- (GSNetworkCacheMemoryManager *)memoryCacheManager {
    if (_memoryCacheManager == nil) {
        _memoryCacheManager = [[GSNetworkCacheMemoryManager alloc] init];
    }
    return _memoryCacheManager;
}

- (GSNetworkCacheDiskManager *)diskCacheManager {
    if (_diskCacheManager == nil) {
        _diskCacheManager = [[GSNetworkCacheDiskManager alloc] init];
    }
    return _diskCacheManager;
}

@end
