//
//  GSNetworkCacheMemoryRecord.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 内存缓存的最小单位
@interface GSNetworkCacheMemoryRecord : NSObject

@property (nonatomic, strong) id                      content;// 数据
@property (nonatomic, strong) NSDate                  *date;// 缓存日期时间
@property (nonatomic, assign) NSTimeInterval          cacheSecond;// 缓存时长

/// 缓存已过期
- (BOOL)isExpired;

@end

NS_ASSUME_NONNULL_END
