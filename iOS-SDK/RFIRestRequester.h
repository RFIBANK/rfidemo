//
//  RFIRestRequester.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 08.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^successBlock)(NSDictionary *result);
typedef void(^errorBlock)(NSDictionary *error);

@interface RFIRestRequester : NSObject

+ (void)request:(NSString *)url
      andMethod:(NSString *)method
      andParams:(NSDictionary *)requestParams
      andSecret:(NSString *)secret
   successBlock:(successBlock)success
        failure:(errorBlock)failure;

@end
