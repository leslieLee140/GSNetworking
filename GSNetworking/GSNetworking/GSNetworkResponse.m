//
//  GSNetworkResponse.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkResponse.h"
#import "NSURLRequest+Parameter.h"
#import "NSDictionary+Trans2String.h"

@interface GSNetworkResponse ()
@property (nonatomic, strong, readwrite) id             content;
@property (nonatomic, copy, readwrite)   NSString       *requestParameterString;
@property (nonatomic, assign, readwrite) GSNetworkError errorType;
@property (nonatomic, copy, readwrite)   NSString       *errorMessage;
@property (nonatomic, assign, readwrite) BOOL           isCached;// 已缓存，作为缓存操作的判断条件，在初始化方法赋值
@end

@implementation GSNetworkResponse

- (instancetype)initWithContent:(nullable id)content request:(NSURLRequest *)request error:(NSError *)error {
    self = [super init];
    if (self) {
        self.requestParameterString = request.requestParameter.transformUrlParameter2String;
        self.content = content;
        self.errorType = [self errorTypeWithError:error];
        self.isCached = NO;
    }
    return self;
}

- (instancetype)initWithContent:(nullable id)content {
    self = [super init];
    if (self) {
        self.content = content;
        self.errorType = [self errorTypeWithError:nil];
        self.isCached = YES;
    }
    return self;
}

- (GSNetworkError)errorTypeWithError:(NSError *)error {
    if (error) {
        GSNetworkError result;
        switch (error.code) {
            case NSURLErrorNotConnectedToInternet: {
                result = GSNetworkErrorNoNetWork;
                self.errorMessage = @"NetworkFailed";
            }
                break;
            case NSURLErrorTimedOut: {
                result = GSNetworkErrorTimeout;
                self.errorMessage = @"ConnectOperationTimeout";
            }
                break;
            case NSURLErrorCancelled: {
                self.errorMessage = @"RequestCancelled";
                result = GSNetworkErrorCancelled;
            }
                break;
            case GSNetworkErrorNeedLogin: {
                self.errorMessage = @"LoginAgain";
                result = GSNetworkErrorNeedLogin;
            }
                break;
            case GSNetworkErrorOther: {
                result = GSNetworkErrorOther;
                self.errorMessage = error.userInfo[@"info"];// status == -1的情况，各个API的原因都不一样，因此增加一个错误信息
            }
                break;
            default:
                result = GSNetworkErrorNoNetWork;
                self.errorMessage = @"NetworkFailed";
                break;
        }
        return result;
    }
    else {
        return GSNetworkErrorNoError;
    }
}

@end
