//
//  GSNetworkCacheMemoryRecord.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "GSNetworkCacheMemoryRecord.h"

@implementation GSNetworkCacheMemoryRecord

- (BOOL)isExpired {
    NSTimeInterval interval = [self.date timeIntervalSinceDate:[NSDate date]];
    return interval > self.cacheSecond;
}

@end
