//
//  NSURLRequest+Parameter.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLRequest (Parameter)

@property (nonatomic, copy) NSDictionary *requestParameter;

@end

NS_ASSUME_NONNULL_END
