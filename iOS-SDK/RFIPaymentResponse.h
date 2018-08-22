//
//  RFIPaymentResponse.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFIPaymentRequest.h"
#import "RFICardThreeDs.h"

@interface RFIPaymentResponse : NSObject
{
    BOOL * _hasErrors;
    NSString * _transactionId;
    NSString * _terminalCode;
    NSString * _sessionKey;
    NSString * _help;
    NSString * _status;
    NSString * _message;
    NSString * _errors;
    RFICardThreeDs * _card3ds;
}

- (id)initWithRequest:(NSDictionary *)paymentRequest;

@property (nonatomic, copy) NSString * transactionId;
@property (nonatomic, copy) NSString * terminalCode;
@property (nonatomic, copy) NSString * sessionKey;
@property (nonatomic, copy) NSString * help;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * message;
@property (nonatomic, copy) NSString * errors;
@property (nonatomic) BOOL * hasErrors;
@property (nonatomic, copy) RFICardThreeDs * card3ds;


@end
