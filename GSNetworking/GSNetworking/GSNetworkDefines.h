//
//  GSNetworkDefines.h
//  GSNetworking
//
//  Created by FumingLeo on 12/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#ifndef GSNetworkDefines_h
#define GSNetworkDefines_h
@class GSNetworkApiManager;
@class GSNetworkResponse;

/// 上传图片数据Key
extern NSString* _Nonnull const kGSNetworkUploadImageDataKeyName;
extern NSString* _Nonnull const kGSNetworkUploadImageDataKeyImageData;

typedef NS_ENUM(NSUInteger, GSNetworkCachePolicy) {
    GSNetworkCachePolicyNoCache = 0,
    GSNetworkCachePolicyMemory,
    GSNetworkCachePolicyDisk
};

typedef NS_ENUM(NSUInteger, GSNetworkError) {
    GSNetworkErrorDefault = 0,     // 默认情况，没有请求过网络
    GSNetworkErrorNoError,         // 没有错误
    GSNetworkErrorNoNetWork,       // 网络不通
    GSNetworkErrorNeedLogin,       // 需要登陆
    GSNetworkErrorTimeout,         // 请求超时
    GSNetworkErrorCancelled,       // 取消请求
    GSNetworkErrorOther            // 其他问题
};

/// 请求结束回调
@protocol GSNetworkApiManagerDelegate <NSObject>

@required
- (void)apiManagerDidSuccess:(GSNetworkApiManager * _Nonnull)manager;
- (void)apiManagerDidFail:(GSNetworkApiManager * _Nonnull)manager;

@end

/// 请求参数
@protocol GSNetworkApiParameterSource <NSObject>

@required
- (NSDictionary *_Nonnull)parameterForApiManager:(GSNetworkApiManager * _Nonnull)manager;

@end

/// 数据整合
@protocol GSNetworkDataReformer <NSObject>

@required
- (id _Nonnull)manager:(GSNetworkApiManager * _Nonnull)manager reformData:(NSDictionary * _Nonnull)data;

@end

///（AOP）拦截器，拦截请求过程中的每一步
@protocol GSNetworkInterceptor <NSObject>

// 是否允许请求
- (BOOL)apiManager:(GSNetworkApiManager * _Nonnull)manager shouldRequestWithParameter:(NSDictionary * _Nonnull)parameter;
// 发起请求之后
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager afterRequestWithParameter:(NSDictionary * _Nonnull)parameter;

// 请求成功之前
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager beforePerformingSuccessWithResponse:(GSNetworkResponse * _Nonnull)response;
// 请求成功之后
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager afterPerformingSuccessWithResponse:(GSNetworkResponse * _Nonnull)response;

// 请求失败之前
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager beforePerformingFailWithResponse:(GSNetworkResponse * _Nonnull)response;
// 请求失败之后
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager afterPerformingFailWithResponse:(GSNetworkResponse * _Nonnull)response;

// 收到response
- (void)apiManager:(GSNetworkApiManager * _Nonnull)manager didReceiveResponse:(GSNetworkResponse * _Nonnull)response;

@end

/// 验证器，定义数据正确还是错误，正确则返回GSNetworkErrorNoError
@protocol GSNetworkValidator <NSObject>

- (GSNetworkError)apiManager:(GSNetworkApiManager * _Nonnull)manager validateParameter:(NSDictionary * _Nonnull)parameter;

- (GSNetworkError)apiManager:(GSNetworkApiManager * _Nonnull)manager validateCallbackData:(NSDictionary * _Nonnull)data;

@end

#endif /* GSNetworkDefines_h */
