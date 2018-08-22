//
//  RFITransactionDetails.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 17.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFITransactionDetails.h"

@implementation RFITransactionDetails

-(id)initWithReponse: (NSDictionary *)response {
    
    if(self = [super init]) {
        _message = [response objectForKey:@"msg"];
        _status = [response objectForKey:@"status"];
        _transactionId = [response objectForKey:@"tid"];
        
        
        if([response objectForKey:@"help"]) {
            _help = [response objectForKey:@"help"];
        }
        
        if([response objectForKey:@"income_total"]) {
            _incomeTotal = [response objectForKey:@"income_total"];
        }
        
        if([response objectForKey:@"partner_income"]) {
            _partnerIncome = [response objectForKey:@"partner_income"];
        }
        
        if([response objectForKey:@"service"]) {
            _serviceName = [response objectForKey:@"service"];
        }
        
        if([response objectForKey:@"transaction_status"]) {
            _transactionStatus = [response objectForKey:@"transaction_status"];
        }
        
    }
    
    return self;
}

@end
