//
//  NSDictionary+Trans2String.m
//  GSNetworking
//
//  Created by FumingLeo on 13/5/2020.
//  Copyright © 2020 FumingLeo. All rights reserved.
//

#import "NSDictionary+Trans2String.h"

@implementation NSDictionary (Trans2String)

- (NSString *)transformUrlParameter2String {
    NSMutableString* parameterString = [NSMutableString string];
    for (NSUInteger i = 0; i < self.count; i ++) {
        NSString* string = nil;
        if (i == 0) {
            string = [NSString stringWithFormat:@"?%@=%@", self.allKeys[i], self.allValues[i]];
        }
    else {
            string = [NSString stringWithFormat:@"&%@=%@", self.allKeys[i], self.allValues[i]];
        }
        [parameterString appendString:string];
    }
    return parameterString;
}

@end
