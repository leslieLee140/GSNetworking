//
//  GSNetworkApiManager.h
//  GSNetworking
//
//  Created by FumingLeo on 12/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSNetworkDefines.h"

@class GSNetworkApiManager;

NS_ASSUME_NONNULL_BEGIN

@interface GSNetworkApiManager : NSObject

@property (nonatomic, weak) id<GSNetworkApiManagerDelegate>         delegate;
@property (nonatomic, weak) id<GSNetworkApiParameterSource>         parameterSource;
@property (nonatomic, weak) id<GSNetworkInterceptor>                interceptor;
@property (nonatomic, weak) id<GSNetworkValidator>                  validator;
@property (nonatomic, weak) NSObject<GSNetworkApiParameterSource>   *child;

// error
@property (nonatomic, assign, readonly) GSNetworkError errorType;
@property (nonatomic, copy, readonly)   NSString       *errorMessage;

// 缓存
@property (nonatomic, assign) GSNetworkCachePolicy cachePolicy;
@property (nonatomic, assign) NSUInteger           cacheSecond;

// loading
@property (nonatomic, assign, readonly) BOOL isLoading;

// 请求数据
- (NSUInteger)requestData;
+ (NSInteger)requestDataWithParams:(NSDictionary * _Nonnull)parameter success:(void (^ _Nullable)(GSNetworkApiManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GSNetworkApiManager * _Nonnull apiManager))failCallback;
- (NSInteger)requestDataWithSuccess:(void (^ _Nullable)(GSNetworkApiManager * _Nonnull apiManager))successCallback fail:(void (^ _Nullable)(GSNetworkApiManager * _Nonnull apiManager))failCallback;

/**
 * 上传图片，数据结构：
  @{
   kGSNetworkUploadImageDataKeyName : @"imageName",
   kGSNetworkUploadImageDataKeyImageData : (NSData *)image]
  }
*/
- (NSUInteger)uploadImages:(NSArray<NSDictionary *> *)images;

/// 获取整合后的数据
- (id)fetchDataWithReformer:(id<GSNetworkDataReformer>)reformer;

/// 取消请求
- (void)cancelRequestWithId:(NSUInteger)requestId;

@end

NS_ASSUME_NONNULL_END
