Библиотека для работы c Alba
=============

#### Инициализация сервиса

Сервис может быть инициализирован двумя способами:

* с передачей параметров serviceId и secret:

```objective-c
	RFIPayService * payService = [[RFIPayService alloc] initWithServiceId:@"12345" andSecret:@"abcd1234"];
```

* с передачей параметров serviceId и key:

```objective-c
	RFIPayService * payService = [[RFIPayService alloc] initWithServiceId:@"12345" andKey:@"abcd1234"];
```

Для проведения оплаты банковской картой с вводом карточных данных необходимо сначала создать токен содержащий данные,
а затем использовать его для инициации платежа. Данные, необходимые для создания токена, содержатся в RFICardTokenRequest.
Если карта требует проведения 3-D Secure проверку, то paymentResponse.card3ds будет содержать данные
для POST запроса на сайт банка-эмитента.

#### Получение токена карты

Инициализируем запрос RFICardTokenRequest:

```objective-c
   	RFICardTokenRequest * cardTokenRequest = [[RFICardTokenRequest alloc] initWithServiceId:payService.serviceId andCard:@"<Номер карты>" andExpMonth:@"<Месяц>" andExpYear:@"<Год>" andCvc:@"<CVC>" andCardHolder:@"<Владелец карты>"];
        RFICardTokenResponse * cardTokenResponse = [payService createCardToken:cardTokenRequest isTest:YES];
```

Запрашиваем токен карты. Метод **[RFIPayService createCardToken: isTest: successBlock: failure:]** выполняется асинхронно. В случае, если ответ от Банка получен, выполняется successBlock, в противном - failure:

```objective-c
	[payService createCardToken:cardTokenRequest isTest:YES successBlock:^(RFICardTokenResponse *response) {
		// обработка ответа от Банка
	} failure:^(NSDictionary *error) {
  		// обработка ошибки
	}];
```

Если cardTokenResponse.hasErrors == NO, инициализируем транзакцию:

```objective-c
        // Генерируем запрос на оплату
        RFIPaymentRequest * paymentRequest = [[RFIPaymentRequest alloc] init];

        // Собираем необходимые параметры для платежа
        paymentRequest.paymentType = @"spg_test";     // Варинаты: mc, qiwi, spg, spg_test
        paymentRequest.email = @"<Email>";            // Может быть обязательным, в зависисмости от настроек сервиса
        paymentRequest.cost = @"<Сумма>";             // в целых
        paymentRequest.name = @"<Название платежа>";        
        paymentRequest.phone = @"<Номер телефона>";   // Обязательно, если канал оплаты mc, qiwi
        paymentRequest.orderId = @"<Номер заказа>";   // Номер заказа должен быть уникальным. Необязательное поле
        paymentRequest.background = @"1";             // Всегда ставим 1
        paymentRequest.cardToken = cardTokenResponse.token;       // В случае, если канал оплаты spg или spg_test        
        paymentRequest.comment = @"<Комментарий>";    // Необязательное поле
```

В случае, если платеж рекуррентный, то paymentRequest необходимо передать дополнительные параметры, описанные в RFIReccurentParams. Рекуррентный платеж (РП) состоит из двух операций:
	
* платеж с регистрацией рекуррентного платежа (для первого РП)

```objective-c
	NSString *url = @"<Ссылка на подробное описание правил предоставления рекуррентного платежа>";
	NSString *comment = @"<Текстовое описание за что производится регистрация РП>";
	RFIReccurentParams *reccurentParams = [RFIReccurentParams firstWithUrl:url andComment:comment];
```

* рекуррентный платеж по требованию (все последующие РП)

```objective-c
	NSString *reccurentOrderId = @"<номер заказа>";
	RFIReccurentParams *reccurentParams = [RFIReccurentParams nextWithOrderId:reccurentOrderId];
```

Затем передаем параметры рекуррентного платежа запросу на оплату:

```objective-c
	paymentRequest.reccurentParams = reccurentParams;
```

#### Инициируем запрос платежа к Банку

Метод **[RFIPayService paymentInit: successBlock: failure:]** выполняется асинхронно. В случае, если ответ от Банка получен, выполняется successBlock, в противном - failure:

```objective-c
   	[payService paymentInit:paymentRequest successBlock:^(RFIPaymentResponse *response) {
   		// обработка ответа от Банка
	} failure:^(NSDictionary *error) {
		// обработка ошибки
	}];
```

Если paymentResponse.hasErrors не содержит ошибок, получаем ID транзакции

```objective-c
  	NSString * transactionId = paymentResponse.transactionId;
```

#### Получаем статус инициализации транзакции:

```objective-c
 	NSString * status = paymentResponse.status;
```

#### Получаем дополнительный текст по оплате (mc):

```objective-c
	NSString * help = paymentResponse.help;
```

#### Если требуется обработка 3DS:

```objective-c
	if(paymentResponse.card3ds) {
		//Обработка 3DS
	}
```

Если 3-D secure требуется, то необходимо сделать POST запрос на адрес paymentResponse.card3ds.ACSUrl с параметрами:

        PaReq - с значением paymentResponse.card3ds.PaReq
        MD - с значением paymentResponse.card3ds.MD
        TermUrl - URL обработчика, на вашем сайте. На него будет возвращён пользователь после прохождения 3DS авторизации       
                
        Для проверки прохождения 3DS авторизации следует вызвать POST запросом API https://partner.rficb.ru/alba/ack3ds/ , передав туда:
        service_id;
        tid или order_id;
        emitent_response - данные, пришедшие от банка-эмитента в виде JSON-encoded словаря (Содержатся в paymentResponse.card3ds)
        check - подпись запроса
        version=2.0 - версия протокола
                

#### Пример для подписи запроса:

```objective-c
        NSString * check = [RFISigner sign:@"строка для подписи"
                                       url:@"URL куда отправляем запрос"
                             requestParams: @{}
                                 secretKey: payService.secret];
```

Также есть возможность воспользоваться готовым termUrl, для этого достаточно указать:

        https://secure.rficb.ru/acquire?sid=<ID-Сервиса>&oid=<ID-Транзакции>&op=pay
                
Или в случае тестовой оплаты:

        https://test.rficb.ru/acquire?sid=<ID-Сервиса>&oid=<ID-Транзакции>&op=pay
          
Получение информации о транзакции. Метод **[RFIPayService transactionDetails: successBlock: failure:]** выполняется асинхронно. В случае, если ответ от Банка получен, выполняется successBlock, в противном - failure:

```objective-c
 	[payService transactionDetails: transactionId successBlock:^(RFIPaymentResponse *response) {
 		// обработка ответа от Банка
	} failure:^(NSDictionary *error) {
		// обработка ошибки
	}];
```

Статус инициализации транзакции. success - успех

```objective-c
        NSString * transactionStatus = transactionDetails.status;
```

Статус проведения платежа. open, error, payed, success

```objective-c
        NSString * transactionPayStatus = transactionDetails.transactionStatus;
```

#### Метод проверки статуса 3DS

```objective-c
- (void) check3DSStatusForService: (NSString *) serviceId
                          orderId: (NSNumber *) orderId
                  emitentResponse: (NSDictionary *) emitentResponse
                     andSecretKey: (NSString *) secretKey
      {
    
      NSString *checkURL = @"https://partner.rficb.ru/alba/ack3ds";
    
      NSError *error;
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:emitentResponse
                                                       options:0
                                                         error:&error];
    
      NSString *emitentResponseJSON;
   
      emitentResponseJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
      NSMutableDictionary *paymentParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                         @"service_id": serviceId,
                                                                                         @"tid": [orderId stringValue],
                                                                                         @"emitent_response": emitentResponseJSON,
                                                                                         @"version": @"2.0"
                                                                                         }];
    
      RFIRestRequester *requester = [[RFIRestRequester alloc] init];
    
      [requester request:checkURL andMethod:@"post" andParams: paymentParams andSecret:secretKey];

      NSLog(@"Ответ 3ds: %@",requester.responseJSONData);  
}
```

#### Получение статуса транзакции:

```objective-c
       TransactionDetails details = service.transactionDetails(response.getSessionKey());
       if (details.getStatus() == TransactionStatus.PAYED || details.getStatus() == TransactionStatus.SUCCESS) {
          // транзакция оплачена
       } else {
          // транзакция не оплачена
       }
```

