//
//  GSNetworkApiManager.m
//  GSNetworking
//
//  Created by FumingLeo on 12/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkApiManager.h"
#import "AFNetworking.h"
#import "GSNetworkResponse.h"
#import "GSNetworkCacheManager.h"
#import "NSDictionary+Trans2String.h"
#import "GSNetworkApiProxy.h"
#import "NSURLRequest+Parameter.h"

@interface GSNetworkApiManager ()
@property (nonatomic, assign) GSNetworkError errorType;
@property (nonatomic, copy)   NSString *errorMessage;
@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;
@property (nonatomic, copy)   id rawData;
@property (nonatomic, strong) NSMutableArray *requestIdList;
@property (nonatomic, copy)   void (^successBlock)(GSNetworkApiManager *manager);
@property (nonatomic, copy)   void (^failBlock)(GSNetworkApiManager *manager);
@property (nonatomic, assign) BOOL isLoading;
@end

@implementation GSNetworkApiManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegate = nil;
        _parameterSource = nil;
        _interceptor = nil;
        _validator = nil;
        
        _cacheSecond = 60*3;// 默认缓存3分钟
        _errorMessage = nil;
        _rawData = nil;
        
        _errorType = GSNetworkErrorDefault;
        
        // 注释原因：参数非必要由子类实现，也可以通过此类的类方法传入❌ 子类（实例）会调用init方法，而类方法不会走这里
        // 子类必须遵循某个协议，以此防止乱继承
        if ([self conformsToProtocol:@protocol(GSNetworkApiParameterSource)]) {
            self.child = (id <GSNetworkApiParameterSource>)self;
        }
        else {
            NSException *exception = [[NSException alloc] init];
            @throw exception;
        }
    }
    return self;
}

// 请求方式①
- (NSUInteger)requestData {
    NSDictionary *parameter = [self.parameterSource parameterForApiManager:self];
    return [self requestDataWithParameter:parameter];
}

// 请求方式②
+ (NSInteger)requestDataWithParams:(NSDictionary *)parameter success:(void (^)(GSNetworkApiManager * _Nonnull))successCallback fail:(void (^)(GSNetworkApiManager * _Nonnull))failCallback {
    return [[[self alloc] init] requestDataWithParams:parameter success:successCallback fail:failCallback];
}

// 请求方式③
- (NSInteger)requestDataWithSuccess:(void (^)(GSNetworkApiManager * _Nonnull))successCallback fail:(void (^)(GSNetworkApiManager * _Nonnull))failCallback {
    NSDictionary *parameter = [self.parameterSource parameterForApiManager:self];
    return [self requestDataWithParams:parameter success:successCallback fail:failCallback];
}

- (NSInteger)requestDataWithParams:(NSDictionary *)parameter success:(void (^)(GSNetworkApiManager * _Nonnull))successCallback fail:(void (^)(GSNetworkApiManager * _Nonnull))failCallback {
    self.successBlock = successCallback;
    self.failBlock = failCallback;
    return [self requestDataWithParameter:parameter];
}

- (NSUInteger)requestDataWithParameter:(NSDictionary *)parameter {
    // Interceptor - 发起请求前
    if ([self.interceptor respondsToSelector:@selector(apiManager:shouldRequestWithParameter:)]) {
        BOOL shouldRequest = [self.interceptor apiManager:self shouldRequestWithParameter:parameter];
        if (shouldRequest == NO) {
            return 0;
        }
    }
    
    self.isLoading = YES;
    
    // Validator - 验证参数
    if ([self.validator respondsToSelector:@selector(apiManager:validateParameter:)]) {
        GSNetworkError errorType = [self.validator apiManager:self validateParameter:parameter];
        if (errorType != GSNetworkErrorNoError) {
            [self failedWithReponse:nil errorType:errorType];
            return 0;
        }
    }
    
    // 提取缓存
    GSNetworkResponse *response = nil;
    if (self.cachePolicy == GSNetworkCachePolicyMemory) {// 内存
        response = [[GSNetworkCacheManager sharedInstance] fetchMemoryCacheWithKey:parameter.transformUrlParameter2String];
    }
    else if (self.cachePolicy == GSNetworkCachePolicyDisk) {// 磁盘
        response = [[GSNetworkCacheManager sharedInstance] fetchDiskCacheWithKey:parameter.transformUrlParameter2String];
    }
    
    if (response) {
        self.rawData = response.content;
        [self successfulWithReponse:response];
        return 0;
    }
    
    __block NSUInteger requestId = 0;
    NSURLRequest *urlRequest = [self getUrlRequestWithParameter:parameter];
    urlRequest.requestParameter = parameter;// 把参数赋给request，response的初始化用到此参数
    
    // 请求数据
    requestId = [[GSNetworkApiProxy sharedInstance] callWithRequest:urlRequest success:^(GSNetworkResponse *response) {
        [self successfulWithReponse:response];
        [self removeRequestId:requestId];
    } fail:^(GSNetworkResponse *response) {
        [self failedWithReponse:response errorType:response.errorType];
        [self removeRequestId:requestId];
    }];
    
    // Interceptor - 发起请求之后
    if ([self.interceptor respondsToSelector:@selector(apiManager:afterRequestWithParameter:)]) {
        [self.interceptor apiManager:self afterRequestWithParameter:parameter];
    }
    
    [self.requestIdList addObject:@(requestId)];
    
    return requestId;
}

- (NSUInteger)uploadImages:(NSArray<NSDictionary *> *)images {
    NSDictionary *parameter = [self.parameterSource parameterForApiManager:self];
    return [self uploadImages:images withParameter:parameter];
}

- (NSUInteger)uploadImages:(NSArray<NSDictionary *> *)images withParameter:(NSDictionary *)parameter {
    // Interceptor - 发起请求前
    if ([self.interceptor respondsToSelector:@selector(apiManager:shouldRequestWithParameter:)]) {
        BOOL shouldRequest = [self.interceptor apiManager:self shouldRequestWithParameter:parameter];
        if (shouldRequest == NO) {
            return 0;
        }
    }
    
    self.isLoading = YES;
    
    // Validator - 验证参数
    if ([self.validator respondsToSelector:@selector(apiManager:validateParameter:)]) {
        GSNetworkError errorType = [self.validator apiManager:self validateParameter:parameter];
        if (errorType != GSNetworkErrorNoError) {
            [self failedWithReponse:nil errorType:errorType];
            return 0;
        }
    }
    
    // 提取缓存
    GSNetworkResponse *response = nil;
    if (self.cachePolicy == GSNetworkCachePolicyMemory) {// 内存
        response = [[GSNetworkCacheManager sharedInstance] fetchMemoryCacheWithKey:parameter.transformUrlParameter2String];
    }
    
    if (self.cachePolicy == GSNetworkCachePolicyDisk) {// 磁盘
        response = [[GSNetworkCacheManager sharedInstance] fetchDiskCacheWithKey:parameter.transformUrlParameter2String];
    }
    
    if (response) {
        self.rawData = response.content;
        [self successfulWithReponse:response];
        return 0;
    }
    
    __block NSUInteger requestId = 0;
    NSURLRequest *urlRequest = [self getUploadUrlRequestWithParameter:parameter];
    urlRequest.requestParameter = parameter;// 把参数赋给request，response的初始化用到此参数
    
    requestId = [[GSNetworkApiProxy sharedInstance] uploadWithReqeust:urlRequest imageDatas:images success:^(GSNetworkResponse * _Nonnull response) {
        [self successfulWithReponse:response];
        [self removeRequestId:requestId];
    } fail:^(GSNetworkResponse * _Nonnull response) {
        [self failedWithReponse:response errorType:response.errorType];
        [self removeRequestId:requestId];
    }];
    
    // Interceptor - 发起请求之后
    if ([self.interceptor respondsToSelector:@selector(apiManager:afterRequestWithParameter:)]) {
        [self.interceptor apiManager:self afterRequestWithParameter:parameter];
    }
    
    return requestId;
}

- (void)cancelRequestWithId:(NSUInteger)requestId {
    [[GSNetworkApiProxy sharedInstance] cancelRequestWithId:requestId];
    [self removeRequestId:requestId];
}

- (void)cancelAllRequests {
    [[GSNetworkApiProxy sharedInstance] cancelRequestWithList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}

- (void)removeRequestId:(NSUInteger)requestId {
    [self.requestIdList removeObject:@(requestId)];
}

- (void)dealloc {
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - 接口URL
- (NSURLRequest*)getUrlRequestWithParameter:(NSDictionary *)parameter {
    return [self.httpRequestSerializer requestWithMethod:@"POST" URLString:@"https://clientegg.vgabc.com/uxapi/" parameters:parameter error:nil];
}
- (NSURLRequest*)getUploadUrlRequestWithParameter:(NSDictionary *)parameter {
    return [self.httpRequestSerializer requestWithMethod:@"POST" URLString:@"https://uxupload-inter.bigeyes.com/upload.php" parameters:parameter error:nil];
}
#pragma mark - Callback

- (void)successfulWithReponse:(GSNetworkResponse*)response {
    self.isLoading = NO;
    self.errorType = GSNetworkErrorNoError;
    self.rawData = response.content;
    
    // Validator - 验证response的数据
    if ([self.validator respondsToSelector:@selector(apiManager:validateCallbackData:)]) {
        GSNetworkError errorType = [self.validator apiManager:self validateCallbackData:response.content];
        if (errorType != GSNetworkErrorNoError) {
            [self failedWithReponse:response errorType:errorType];
            return;
        }
    }
    
    // 缓存
    if (response.isCached == NO) {
        if (self.cachePolicy == GSNetworkCachePolicyMemory) {
            [[GSNetworkCacheManager sharedInstance] saveMemoryCacheWithReponse:response forSecond:self.cacheSecond];
        }
        else if (self.cachePolicy == GSNetworkCachePolicyDisk) {
            [[GSNetworkCacheManager sharedInstance] saveDiskCacheWithReponse:response forSecond:self.cacheSecond];
        }
    }
    
    // Interceptor - 收到response
    if ([self.interceptor respondsToSelector:@selector(apiManager:didReceiveResponse:)]) {
        [self.interceptor apiManager:self didReceiveResponse:response];
    }
    
    // Interceptor - 执行”请求成功的代理方法“之前
    if ([self.interceptor respondsToSelector:@selector(apiManager:beforePerformingSuccessWithResponse:)]) {
        [self.interceptor apiManager:self beforePerformingSuccessWithResponse:response];
    }
    
    // 执行”请求成功的代理方法“
    if ([self.delegate respondsToSelector:@selector(apiManagerDidSuccess:)]) {
        [self.delegate apiManagerDidSuccess:self];
    }
    
    if (self.successBlock) {
        self.successBlock(self);
    }
    
    // Interceptor - 执行”请求成功的代理方法“之后
    if ([self.interceptor respondsToSelector:@selector(apiManager:afterPerformingSuccessWithResponse:)]) {
        [self.interceptor apiManager:self afterPerformingSuccessWithResponse:response];
    }
}

- (void)failedWithReponse:(GSNetworkResponse*)response errorType:(GSNetworkError)errorType {
    self.errorType = errorType;
    self.isLoading = NO;
    self.errorMessage = response.errorMessage;
    
    // Interceptor - 收到response
    if ([self.interceptor respondsToSelector:@selector(apiManager:didReceiveResponse:)]) {
        [self.interceptor apiManager:self didReceiveResponse:response];
    }
    
    // Interceptor - 执行”请求失败的代理方法“之前
    if ([self.interceptor respondsToSelector:@selector(apiManager:beforePerformingFailWithResponse:)]) {
        [self.interceptor apiManager:self beforePerformingFailWithResponse:response];
    }
    
    // 执行”请求失败的代理方法“
    if ([self.delegate respondsToSelector:@selector(apiManagerDidFail:)]) {
        [self.delegate apiManagerDidFail:self];
    }
    
    if (self.failBlock) {
        self.failBlock(self);
    }
    
    // Interceptor - 执行”请求失败的代理方法“之后
    if ([self.interceptor respondsToSelector:@selector(apiManager:afterPerformingFailWithResponse:)]) {
        [self.interceptor apiManager:self afterPerformingFailWithResponse:response];
    }
}

#pragma mark - Data reform

- (id)fetchDataWithReformer:(id<GSNetworkDataReformer>)reformer {
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        resultData = [reformer manager:self reformData:self.rawData];
    }
    else {
        resultData = [self.rawData mutableCopy];
    }
    return resultData;
}

#pragma mark - Getter & Setter

- (AFHTTPRequestSerializer *)httpRequestSerializer {
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _httpRequestSerializer;
}

- (NSMutableArray *)requestIdList {
    if (_requestIdList == nil) {
        _requestIdList = [NSMutableArray arrayWithCapacity:0];
    }
    return _requestIdList;
}

- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

@end
