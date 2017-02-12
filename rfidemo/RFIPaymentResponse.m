//
//  RFIPaymentResponse.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFIPaymentResponse.h"

@implementation RFIPaymentResponse

- (id) initWithRequest: (NSDictionary *)paymentRequest {
    self = [super init];
    
    if(self) {

        _status = [paymentRequest objectForKey:@"status"];
        
        //если получили ошибки
        if([_status isEqualToString:@"error"]) {
            _hasErrors = (BOOL *) YES;
            _message = [paymentRequest objectForKey:@"message"];
            _errors = [paymentRequest objectForKey:@"errors"];
        }
        
        //если успех
        if([_status isEqualToString:@"success"]) {
            
            if([paymentRequest objectForKey:@"3ds"]) {

                RFICardThreeDs * threeDS = [[RFICardThreeDs alloc] initWithParams: [paymentRequest objectForKey:@"3ds"]];
                
                _card3ds = threeDS;
                
            }

            _help = [paymentRequest objectForKey:@"help"];
            _transactionId = [paymentRequest objectForKey:@"tid"];
        }

    }
    
    return self;
}

@end
