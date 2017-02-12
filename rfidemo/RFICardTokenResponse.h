//
//  RFICardTokenResponse.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 17.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFICardTokenRequest.h"
#import "RFIRestRequester.h"

@interface RFICardTokenResponse : NSObject
{
    BOOL * _hasErrors;
    NSString * _errorDetails;
    NSString * _message;
    NSString * _status;
    NSString * _token;
    NSDictionary * _errors;
}

@property (nonatomic) BOOL * hasErrors;
@property (nonatomic, copy) NSString * errorDetails;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * token;
@property (nonatomic, copy) NSDictionary * errors;

-(id) initWithRequest: (NSDictionary *)cardTokenRequest;

@end
