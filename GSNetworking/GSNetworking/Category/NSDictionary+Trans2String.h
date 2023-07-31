//
//  NSDictionary+Trans2String.h
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Trans2String)

/// URL参数转成字符串
- (NSString *)transformUrlParameter2String;

@end

NS_ASSUME_NONNULL_END
