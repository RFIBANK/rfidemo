//
//  FSRFIAPI.m
//  FlowersShop
//
//  Фасад для работы с RFI API
//
//  Created by Кирилл on 10.02.17.
//  Copyright © 2017 Кирилл. All rights reserved.
//

#import "FSRFIAPI.h"
#import "RFIPay.h"
#import "RFICardTokenRequest.h"
#import "RFICardTokenResponse.h"
#import "RFISigner.h"
#import "RFITransactionDetails.h"
#import "RFIReccurentParams.h"

#define FS_ERROR_TITLE @"Ошибка оплаты"
#define FS_EROR_UNKNOWN_ERROR @"Неизвестная ошибка"

@interface FSRFIAPI()

@property (nonatomic, strong) NSString *serviceId;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic) BOOL testMode;

@property (nonatomic, strong) NSString *lastTransactionId;
@property (nonatomic, strong) NSString *sessionKey;

@end

@implementation FSRFIAPI
    
- (id) initWithServideId: (id) serviceId key: (NSString *) key andTestMode: (BOOL) testMode
    {
        self = [super init];
        
        if (self)
        {
            _serviceId = [NSString stringWithFormat:@"%@", serviceId];
            _key = key;
            _testMode = testMode;
        }
        
        return self;
    }

- (id) initWithServideId: (id) serviceId secret: (NSString *) secret andTestMode: (BOOL) testMode
{
    self = [super init];
    
    if (self)
    {
        _serviceId = [NSString stringWithFormat:@"%@", serviceId];
        _secret = secret;
        _testMode = testMode;
    }
    
    return self;
}

#pragma mark Payment

- (void) makeReccurentPayment: (NSString *) recurrentOrderId orderId: (NSString *) orderId  orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success failCallback: (void (^)(NSError *error)) fail
{
    
    RFIPayService *payService = [[RFIPayService alloc] initWithServiceId:_serviceId andSecret:_secret];
    
    RFIPaymentRequest *paymentRequest = [[RFIPaymentRequest alloc] init];
    
    paymentRequest.paymentType = (_testMode) ? @"spg_test" : @"spg";
    paymentRequest.cost = [NSString stringWithFormat:@"%@", sum];
    paymentRequest.name = orderName;
    paymentRequest.orderId = recurrentOrderId;
    paymentRequest.comment = comment;
    paymentRequest.background = @"1";
    
    // Включение реккурентов
    paymentRequest.reccurentParams = [RFIReccurentParams nextWithOrderId: recurrentOrderId];
    
    [payService paymentInit:paymentRequest successBlock:^(RFIPaymentResponse *paymentResponse) {
        NSLog(@"Reccurent paymentResponse: %@", paymentResponse);
        if(!paymentResponse.hasErrors) {
            success();
        } else {
            // Ошибка оплаты
            if (fail != nil)
            {
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: (paymentResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : paymentResponse.message
                                            };
                NSError *error = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:100 userInfo:errorDict];
                fail(error);
            }
        }
    } failure:^(NSDictionary *error) {
        // обработка ошибки
        NSDictionary *errorDict = @{
                                    NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                    NSLocalizedFailureReasonErrorKey: [[error objectForKey: @"Error"] valueForKey: @"message"]
                                    };
        NSError *errorReturn = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:300 userInfo:errorDict];
        fail(errorReturn);
    }];
    
}

- (void) makePaymentWithCard: (FSCreditCard *) card orderId:(id) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success secureCallback: (void (^)(NSString *htmlFormData)) secure failCallback: (void (^)(NSError *error)) fail
{
    // Инициализируем сервис оплаты v2
    RFIPayService *payService = [[RFIPayService alloc] initWithServiceId:_serviceId andSecret:_secret];
    
    // Билдим запрос на создание токена карт
    RFICardTokenRequest *cardTokenRequest = [[RFICardTokenRequest alloc] initWithServiceId:_serviceId
                                                                                   andCard:card.PAN
                                                                               andExpMonth:card.expirityMonth
                                                                                andExpYear:card.expirityYear
                                                                                    andCvc:card.CVC
                                                                             andCardHolder:card.cardholder];
    // Отпарвляем запрос на создание токена
    [payService createCardToken:cardTokenRequest isTest:YES successBlock:^(RFICardTokenResponse *cardTokenResponse) {
        
        if(!cardTokenResponse.hasErrors) {
            
            NSString *cardToken = cardTokenResponse.token;
            
            // Если нет ошибок, строим запрос на оплату
            RFIPaymentRequest *paymentRequest = [[RFIPaymentRequest alloc] init];
            
            paymentRequest.paymentType = (_testMode) ? @"spg_test" : @"spg";
            paymentRequest.cost = [NSString stringWithFormat:@"%@", sum];
            paymentRequest.orderId = [NSString stringWithFormat:@"%@", orderId];
            paymentRequest.name = orderName;
            paymentRequest.comment = comment;
            paymentRequest.background = @"1"; // Назначение параметра остаётся загадкой, но сказали так делать всегда
            paymentRequest.cardToken = cardToken;
            
            paymentRequest.email = @"test@mail.ru"; // Обязателен для рекурентных платежей
            
            // Включение реккурентов
            NSString *url = @"http://url.test.ru";
            NSString *comment = @"<Текстовое описание за что производится регистрация РП>";
            RFIReccurentParams * reccurentParams = [RFIReccurentParams firstWithUrl:url andComment:comment];
            reccurentParams.orderId = [NSString stringWithFormat:@"%@", orderId];
            paymentRequest.reccurentParams = reccurentParams;
            
            // Отправляем запрос на оплату
            // Вероятных исходов три:
            // - Заказ оплатится
            // - Заказ не оплатится
            // - Заказа не оплатится, потому что нужно пройти проверку 3DS
            
//              RFIPaymentResponse *paymentResponse = (RFIPaymentResponse *) [payService paymentInit:paymentRequest];
            [payService paymentInit:paymentRequest successBlock:^(RFIPaymentResponse *paymentResponse) {
                
                // сохраняем SessionKey для дальнейшего получения статуса транзакции
                self.sessionKey = paymentResponse.sessionKey;
                
                if(!paymentResponse.hasErrors) {
                    
                    _lastTransactionId = paymentResponse.transactionId;
                    
                    // Если есть объект на card3ds значит нужно проходить проверку 3DS
                    if(paymentResponse.card3ds) {
                        
                        NSString *termURL = [self termURLForTransactionId:paymentResponse.transactionId];
                        
                        // Самый простой способ отправить POST запрос с необходимыми данными эмитенту это воспользоватся готовой
                        // формой с автосабмитом и отдать его в веб вью
                        
                        NSString *rawFormDataPath = [[NSBundle mainBundle] pathForResource:@"card_3ds_form" ofType:nil];
                        NSString *rawFormData = [NSString stringWithContentsOfFile:rawFormDataPath encoding:NSUTF8StringEncoding error:nil];
                        
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${ACSUrl}" withString:paymentResponse.card3ds.ACSUrl];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${MD}" withString:paymentResponse.card3ds.MD];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${PaReq}" withString:paymentResponse.card3ds.PaReq];
                        rawFormData = [rawFormData stringByReplacingOccurrencesOfString:@"${TermUrl}" withString:termURL];
                        
                        // Колбеки выполняем в основном потоке
                        dispatch_async(dispatch_get_main_queue(), ^{
                            secure(rawFormData);
                        });
                    } else {
                        // Успешная оплата
                        // Колбеки выполняем в основном потоке
                        dispatch_async(dispatch_get_main_queue(), ^{
                            success();
                        });
                    }
                } else {
                    // Ошибка оплаты
                   
                        if (fail != nil)
                        {
                            NSDictionary *errorDict = @{
                                                        NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                                        NSLocalizedFailureReasonErrorKey: (paymentResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : paymentResponse.message
                                                        };
                            NSError *error = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:100 userInfo:errorDict];
                            fail(error);
                        }
                }
            } failure:^(NSDictionary *error) {
                // обработка ошибки
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: [[error objectForKey: @"Error"] valueForKey: @"message"]
                                            };
                NSError *errorReturn = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:300 userInfo:errorDict];
                fail(errorReturn);
            }];
        }else{
            // Ошибка при получении токена карты
            if (fail != nil)
            {
                NSDictionary *errorDict = @{
                                            NSLocalizedDescriptionKey: FS_ERROR_TITLE,
                                            NSLocalizedFailureReasonErrorKey: (cardTokenResponse.message == nil) ? FS_EROR_UNKNOWN_ERROR : cardTokenResponse.message
                                            };
                NSError *error = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:200 userInfo:errorDict];
                fail(error);
            }
        }
    } failure:^(NSDictionary *error) {
        // обработка ошибки
        NSLog(@"Error - %@", error);
        NSDictionary *errorDict = @{
                                    NSLocalizedDescriptionKey: FS_EROR_UNKNOWN_ERROR,
                                    NSLocalizedFailureReasonErrorKey: @"Возникла ошибка при обращении к банку. Проверьте соединение с интернетом." //[error valueForKey: @"message"]
                                    };
        NSError *errorResponse = [[NSError alloc] initWithDomain:FS_RFI_API_ERROR_DOMAIN code:200 userInfo:errorDict];
        fail(errorResponse);
    }];
  
}

// TO DO протестировать
- (void) getLastTransactionStatus: (void (^)(FSOnlinePaymentStatus status)) callback
{
    NSLog(@"Transaction ID is %@", _lastTransactionId);
    if (_lastTransactionId == nil)
    {
        callback(FSOnlinePaymentStatusFailed);
    }
}

- (NSString *) termURL
{
    return [self termURLForTransactionId:_lastTransactionId];
}

- (NSString *) sessionKey
{
    return _sessionKey;
}

#pragma mark - Helpers

- (NSString *) termURLForTransactionId: (NSString *) transactionId
{
    // Будем пользоватся готовыми TermURL от банка, которые автоматически завершат транзакцию и нам не придется возиться
    // с отправкой POST запросов экваеру после завершения проверки 3DS
    if (_testMode)
    {
        return [NSString stringWithFormat:@"https://test.rficb.ru/acquire?sid=%@&oid=%@&op=pay", _serviceId, transactionId];
    }
    return [NSString stringWithFormat:@"https://secure.rficb.ru/acquire?sid=%@&oid=%@&op=pay", _serviceId, transactionId];
}

@end
