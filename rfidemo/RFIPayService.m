//
//  RFIPayService.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFIPayService.h"
#import "RFIPaymentResponse.h"
#import "RFIHelpers.h"
#import "RFISigner.h"
#import "RFIRestRequester.h"
#import "RFIConnectionProfile.h"
#import "RFITransactionDetails.h"

@implementation RFIPayService


// Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams {
    
    //
    NSString * string = @"";
    string = [string stringByAppendingFormat: @"%@%@", _serviceId, _secret];
    string = [string md5];
    
    return string;
}

- (id) initWithKey: (NSString *)key {
    
    if(self = [super init]) {
        self.key = key;
    }
    
    return self;
}

- (id) initWithServiceId: (NSString *)serviceId andSecret : (NSString *)secret {
    
    if(self = [super init]) {
        _secret = secret;
        _serviceId = serviceId;
    }
    
    return self;
}


// TODO надо ли дедать?
+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest {
    
    return @"";
}

//
// Иницировать платеж
//

- (id) paymentInit: (RFIPaymentRequest *)paymentRequest {
    
    
    NSMutableDictionary * requestMutableParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                  @"2.0", @"version",
                                                  _serviceId, @"service_id",
                                                  paymentRequest.paymentType,@"payment_type",
                                                  paymentRequest.cost, @"cost",
                                                  paymentRequest.name,@"name",
                                                  nil];
    
    if(paymentRequest.email){
        [requestMutableParams setObject:paymentRequest.email forKey:@"email"];
    }
    
    if(paymentRequest.phone){
        [requestMutableParams setObject:paymentRequest.phone forKey:@"phone_number"];
    }
    
    if(paymentRequest.orderId){
        [requestMutableParams setObject:paymentRequest.orderId forKey:@"order_id"];
    }
    
    if(paymentRequest.cardToken){
        [requestMutableParams setObject:paymentRequest.cardToken forKey:@"card_token"];
    }
    
    if(paymentRequest.comment){
        [requestMutableParams setObject:paymentRequest.comment forKey:@"comment"];
    }
    
    if(paymentRequest.background){
        [requestMutableParams setObject:paymentRequest.background forKey:@"background"];
    } else {
        [requestMutableParams setObject:@"0" forKey:@"background"];
    }
    
    if(paymentRequest.commissionMode){
        [requestMutableParams setObject:paymentRequest.commissionMode forKey:@"commission"];
    }
    
    NSDictionary * requestParams = [requestMutableParams copy];
    // Инициализация платежа
    
    @try {
        NSString * hostUrl =  [[RFIConnectionProfile alloc] baseUrl];
        
        NSString * url = [hostUrl stringByAppendingString:@"alba/input"];
        
        NSDictionary * restRequest = [[RFIRestRequester alloc] request: url
                                                             andMethod: @"POST"
                                                             andParams: requestParams
                                                             andSecret:_secret];
//         NSLog(@"restRequest is %@", restRequest);
        
        RFIPaymentResponse * paymentResponse = [[RFIPaymentResponse alloc] initWithRequest:restRequest];
        return paymentResponse;
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
}

//
// Получить токен карты
//

- (RFICardTokenResponse *) createCardToken: (RFICardTokenRequest *)request isTest: (BOOL) isTest {
    
    NSDictionary * requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"2.0", @"version",
                                    request.card, @"card",
                                    _serviceId, @"service_id",
                                    request.expMonth, @"exp_month",
                                    request.expYear, @"exp_year",
                                    request.cvc, @"cvc",
                                    @"1", @"background",
                                    nil];
    
    @try {
        NSString * hostUrl = @"";
        if(isTest) {
            hostUrl = [hostUrl stringByAppendingString: [[RFIConnectionProfile alloc] cardTokenTestUrl]];
        } else {
            hostUrl = [hostUrl stringByAppendingString: [[RFIConnectionProfile alloc] cardTokenUrl]];
        }
        
        NSString * url = [hostUrl stringByAppendingString:@"create"];
        
        NSDictionary * restRequest = [[RFIRestRequester alloc] request: url
                                                             andMethod: @"POST"
                                                             andParams: requestParams
                                                             andSecret:_secret];
        // NSLog(@"restRequest is %@", restRequest);
        
        RFICardTokenResponse * cardTokenResponse = [[RFICardTokenResponse alloc] initWithRequest:restRequest];
        return cardTokenResponse;
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
}

//
// Получить детали транзакции
//

- (id) transactionDetails: (NSString *) transactionId {
    
    RFITransactionDetails * transactionDetails = [RFITransactionDetails alloc];
    
    NSDictionary * requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"2.0", @"version",
                                    [NSString stringWithFormat:@"%@",transactionId], @"tid",
                                    _serviceId, @"service_id",
                                    nil];
    
    @try {
        NSString * hostUrl = [[RFIConnectionProfile alloc] baseUrl];
        
        NSString * url = [hostUrl stringByAppendingString:@"alba/details"];
        
        NSDictionary * restRequest = [[RFIRestRequester alloc] request: url
                                                             andMethod: @"POST"
                                                             andParams: requestParams
                                                             andSecret:_secret];
//        NSLog(@"restRequest is %@", restRequest);
        
        transactionDetails = [transactionDetails initWithReponse:restRequest];
        
        
    } @catch (NSException *exception) {
        NSLog (@"Обнаружена ошибка с именем %@ и по причине %@.", [exception name], [exception reason]);
    }
    
    return transactionDetails;
}

@end
