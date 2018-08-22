//
//  FSRFIAPI.h
//  FlowersShop
//
//  Фасад для работы с RFI API
//
//  Created by Кирилл on 10.02.17.
//  Copyright © 2017 Кирилл. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FSCreditCard.h"

// Для упрощения статуса будет два — оплачен и неоплачен
typedef enum : NSUInteger {
    FSOnlinePaymentStatusSuccess,
    FSOnlinePaymentStatusFailed
} FSOnlinePaymentStatus;

#define FS_RFI_API_ERROR_DOMAIN @"FS_RFI_API"

@interface FSRFIAPI : NSObject
    
- (id) initWithServideId: (id) serviceId key: (NSString *) key andTestMode: (BOOL) testMode;
- (id) initWithServideId: (id) serviceId secret: (NSString *) secret andTestMode: (BOOL) testMode;

- (void) makePaymentWithCard: (FSCreditCard *) card orderId:(id) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
             successCallback: (void (^)()) success secureCallback: (void (^)(NSString *htmlFormData)) secure failCallback: (void (^)(NSError *error)) fail;

- (void) makeReccurentPayment: (NSString *) orderId orderName: (NSString *) orderName comment: (NSString *) comment andSum: (NSNumber *) sum
              successCallback: (void (^)()) success failCallback: (void (^)(NSError *error)) fail;

- (void) getLastTransactionStatus: (void (^)(FSOnlinePaymentStatus status)) callback;

- (NSString *) termURL;
- (NSString *) sessionKey;

@end
