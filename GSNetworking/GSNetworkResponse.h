//
//  GSNetworkResponse.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSNetworkDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络响应类
@interface GSNetworkResponse : NSObject
@property (nonatomic, strong, readonly) id                                  content;
@property (nonatomic, copy, readonly)   NSString                            *requestParameterString;
@property (nonatomic, assign, readonly) GSNetworkError                      errorType;
@property (nonatomic, assign, readonly) BOOL                                isCached;
@property (nonatomic, copy, readonly)   NSString                            *errorMessage;

/// 初始化方式①，从网络拿到数据后使用
- (instancetype)initWithContent:(nullable id)content request:(NSURLRequest *)request error:(nullable NSError *)error;

/// 初始化方式②，从缓存中提取数据后使用
- (instancetype)initWithContent:(nullable id)content;

@end

NS_ASSUME_NONNULL_END
