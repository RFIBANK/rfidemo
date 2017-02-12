//
//  RFIRestRequester.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 08.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFIRestRequester : NSObject
{
    NSDictionary * _responseJSONData;
}

@property (strong) NSDictionary * responseJSONData;

- (NSDictionary *) request: (NSString *)url andMethod:(NSString *)method andParams:(NSDictionary *)requestParams andSecret:(NSString *)secret;

@end
