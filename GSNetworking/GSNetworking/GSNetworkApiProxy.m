//
//  GSNetworkApiProxy.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkApiProxy.h"
#import "AFHTTPSessionManager.h"
#import "GSNetworkDefines.h"
#import "NSURLRequest+Parameter.h"

NSString * const kGSNetworkUploadImageDataKeyName      = @"kGSNetworkUploadImageDataKeyName";
NSString * const kGSNetworkUploadImageDataKeyImageData = @"kGSNetworkUploadImageDataKeyImageData";

@interface GSNetworkApiProxy ()
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;
@property (nonatomic, strong) NSMutableDictionary  *dispatchTable;
@end

@implementation GSNetworkApiProxy

+ (instancetype)sharedInstance {
    static GSNetworkApiProxy *apiProxy = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiProxy = [[GSNetworkApiProxy alloc] init];
    });
    return apiProxy;
}

- (NSUInteger)uploadWithReqeust:(NSURLRequest *)request imageDatas:(NSArray<NSDictionary *> *)imageDatas success:(GSNetworkApiProxyCallback)successBlock fail:(GSNetworkApiProxyCallback)failBlock {
    
    __block NSURLSessionDataTask *dataTask = nil;
    dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
//        NSLog(@"请求线程：%@", [NSThread currentThread]);
        dataTask = [self.httpSessionManager POST:[NSString stringWithFormat:@"%@", request.URL] parameters:request.requestParameter headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            if (imageDatas.count > 0) {
                for (NSDictionary *data in imageDatas) {
                    if ([data.allKeys containsObject:kGSNetworkUploadImageDataKeyName] &&
                        [data.allKeys containsObject:kGSNetworkUploadImageDataKeyImageData]) {
                        NSString *name = data[kGSNetworkUploadImageDataKeyName];
                        NSData *imageData = data[kGSNetworkUploadImageDataKeyImageData];
                        [formData appendPartWithFileData:imageData name:name fileName:@"avatarfile" mimeType:@"image/png"];
                    }
                    else {
                        NSLog(@"上传图片失败：图片的数据格式错误！");
                    }
                }
            }
        } progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self.dispatchTable removeObjectForKey:@(dataTask.taskIdentifier)];
            
            GSNetworkResponse *urlResponse = [[GSNetworkResponse alloc] initWithContent:responseObject request:request error:nil];
            !successBlock ?: successBlock(urlResponse);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self.dispatchTable removeObjectForKey:@(dataTask.taskIdentifier)];
            
            GSNetworkResponse *urlResponse = [[GSNetworkResponse alloc] initWithContent:nil request:request error:nil];
            !failBlock ?: failBlock(urlResponse);
        }];
        
        self.dispatchTable[@(dataTask.taskIdentifier)] = dataTask;
    });
    
    return dataTask.taskIdentifier;
}

- (NSUInteger)callWithRequest:(NSURLRequest*)request success:(GSNetworkApiProxyCallback)successBlock fail:(GSNetworkApiProxyCallback)failBlock {
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.httpSessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self.dispatchTable removeObjectForKey:@(dataTask.taskIdentifier)];
        
        // “需重新登录”等公共结果纳入失败范畴
//        if (responseObject[@"status"]) {
//            NSInteger status = [responseObject[@"status"] integerValue];
//            if (status == -9) {
//                error = [NSError errorWithDomain:NSURLErrorDomain code:GSNetworkErrorNeedLogin userInfo:nil];
//            }
//            else if (status == -1 || status < 0) {
//                error = [NSError errorWithDomain:NSURLErrorDomain code:GSNetworkErrorOther userInfo:@{@"info" : responseObject[@"msg"]}];
//            }
//        }
        
        GSNetworkResponse *urlResponse = [[GSNetworkResponse alloc] initWithContent:responseObject request:request error:error];
        if (error) {
            !failBlock ?: failBlock(urlResponse);
        }
        else {
            !successBlock ?: successBlock(urlResponse);
        }
    }];
    
    dispatch_queue_t queue = dispatch_queue_create("", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
//        NSLog(@"请求线程：%@", [NSThread currentThread]);
        [dataTask resume];
    });
    
    self.dispatchTable[@(dataTask.taskIdentifier)] = dataTask;
    
    return dataTask.taskIdentifier;
}

- (void)cancelRequestWithId:(NSUInteger)requestId {
    NSURLSessionDataTask *task = self.dispatchTable[@(requestId)];
    [task cancel];
    [self.dispatchTable removeObjectForKey:@(requestId)];
}

- (void)cancelRequestWithList:(NSArray *)requestIdlist {
    for (NSNumber *requestId in requestIdlist) {
        [self cancelRequestWithId:[requestId integerValue]];
    }
}

- (AFHTTPSessionManager *)httpSessionManager {
    if (_httpSessionManager == nil) {
        _httpSessionManager = [AFHTTPSessionManager manager];
    }
    return _httpSessionManager;
}

- (NSMutableDictionary *)dispatchTable {
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}

@end
