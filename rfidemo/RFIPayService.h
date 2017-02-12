//
//  RFIPayService.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 07.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFIPay.h"
#import "RFIPaymentRequest.h"
#import "RFIPaymentResponse.h"
#import "RFICardTokenRequest.h"
#import "RFICardTokenResponse.h"

@interface RFIPayService : NSObject {
    NSString * _key;
    NSString * _secret;
    NSString * _serviceId;
}

@property (nonatomic, copy) NSString * key;
@property (nonatomic, copy) NSString * secret;
@property (nonatomic) NSString * serviceId;

//-(NSString *) commissionAbonent;
//-(NSString *) commissionPartner;

// OLD
//- (id) initWithKey: (NSString *)key;
- (id) initWithServiceId: (NSString *)serviceId andSecret: (NSString *)secret;

// Иницировать платеж
- (id) paymentInit: (RFIPaymentRequest *)request;

// Получение списка доступных способов оплаты для сервиса
//- (id) paymentTypes;

// Получение статуса транзакции
//- (id) transactionDetails: (NSString *) sessionKey;
- (id) transactionDetails: (NSString *) transactionId;

// TODO CLASS RFIRefundRequest
// Запрос на проведение возврата
//- (id) refundResponse: (RFIRefundRequest *)refundRequest;

// Создание токена для оплаты
- (RFICardTokenResponse *) createCardToken: (RFICardTokenRequest *)request isTest: (BOOL) isTest;

// Подпись Version 2.0
- (NSString *) generateCheck: (NSDictionary *)requestParams;

// Подпись Version 1.0 1.1 1.2
//- (NSString *) generateCheckOldVersion;

// Генерация строки запроса на сервер банка из переданных параметров
+ (NSString *) generateUrlForRequest: (RFIPaymentRequest *)paymentRequest;

@end
