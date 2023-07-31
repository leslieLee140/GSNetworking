//
//  NSURLRequest+Parameter.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "NSURLRequest+Parameter.h"
#import <objc/runtime.h>

static void *GSNetworkingRequestParameter = &GSNetworkingRequestParameter;

@implementation NSURLRequest (Parameter)

- (void)setRequestParameter:(NSDictionary *)requestParameter {
    objc_setAssociatedObject(self, GSNetworkingRequestParameter, requestParameter, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParameter {
    return objc_getAssociatedObject(self, GSNetworkingRequestParameter);
}

@end
