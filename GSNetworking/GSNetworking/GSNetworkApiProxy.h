//
//  GSNetworkApiProxy.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSNetworkResponse.h"

typedef void (^GSNetworkApiProxyCallback)(GSNetworkResponse* _Nonnull response);

NS_ASSUME_NONNULL_BEGIN

@interface GSNetworkApiProxy : NSObject

+ (instancetype)sharedInstance;

/// 请求
- (NSUInteger)callWithRequest:(NSURLRequest *)request success:(GSNetworkApiProxyCallback)successBlock fail:(GSNetworkApiProxyCallback)failBlock;

/**
 * 上传图片
*/
- (NSUInteger)uploadWithReqeust:(NSURLRequest *)request imageDatas:(NSArray<NSDictionary *> *)imageDatas success:(GSNetworkApiProxyCallback)successBlock fail:(GSNetworkApiProxyCallback)failBlock;

/// 取消一个请求
- (void)cancelRequestWithId:(NSUInteger)requestId;

/// 取消一些请求
- (void)cancelRequestWithList:(NSArray *)requestIdlist;

@end

NS_ASSUME_NONNULL_END
