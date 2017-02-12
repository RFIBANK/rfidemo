//
//  RFIRestRequester.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 08.09.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFIRestRequester.h"
#import "RFISigner.h"
#import "RFIPayservice.h"
#import "RFIConnectionProfile.h"

@implementation RFIRestRequester


//NSDictionary * returnDictonary = [NSDictionary dictionary];


//@synthesize responseJSONData = _responseJSONData;

- (NSDictionary *) request: (NSString *)url andMethod:(NSString *)method andParams:(NSDictionary *)requestParams andSecret:(NSString *)secret {
    
    NSString * urlAsString = url;
    
    // Формирование подписи запроса
    NSString * check = [RFISigner sign :method url:urlAsString requestParams:requestParams secretKey:secret];
    NSString * urlParametrs = @"";
    
    NSURL *urlLink = [NSURL URLWithString:urlAsString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:urlLink ];
    
    [urlRequest setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:method];
    [urlRequest setValue:@"UTF-8" forHTTPHeaderField:@"content-charset"];
    
    // перебираем все параметры запроса
    for (id key in requestParams) {
        id object = [requestParams objectForKey:key];
        
        if([urlParametrs length] > 0) {
            urlParametrs = [urlParametrs stringByAppendingString: @"&"];
        }
        
        NSString * escapedString = [object stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        
        escapedString = [RFISigner escapeString:escapedString];
        
        urlParametrs = [urlParametrs stringByAppendingFormat: @"%@=%@", key, escapedString];
        
    }
    
    urlParametrs = [urlParametrs stringByAppendingFormat:@"&check=%@", check];
//    NSLog(@"urlParametrs %@", urlParametrs);
    
    // GET request
    if([[method uppercaseString] isEqualToString: @"GET"]) {
        urlParametrs = [@"?" stringByAppendingString: urlParametrs];
    } else {
        // Добавление POST к запросу
        [urlRequest setHTTPBody:[urlParametrs dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
//    NSLog(@"urlParametrs %@", urlParametrs);
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
//    NSLog(@"data is %@", data);
    
    if ([data length] >0  &&
        error == nil){
        
        NSError *e = nil;
        NSDictionary * jsonData = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
        
        if (!jsonData) {
            NSDictionary * errorMessage = @{@"status": @"error", @"message" : [NSString stringWithFormat:@"Error parsing JSON: %@", e]};
            self.responseJSONData = errorMessage;
            
            NSLog(@"Error parsing JSON: %@", e);
        } else {
            self.responseJSONData = jsonData;
        }
        
//        NSLog(@"HTML = %@", html);
    }
    else if ([data length] == 0 &&
             error == nil){
        NSDictionary * errorMessage = @{@"status": @"error", @"message" : @"Empty HTTP response."};
        self.responseJSONData = errorMessage;
        
        NSLog(@"Empty HTTP response.");
    }
    else if (error != nil){
        NSDictionary * errorMessage = @{@"status": @"error", @"message" : [NSString stringWithFormat: @"HTTP error happened = %@", error]};
        self.responseJSONData = errorMessage;
        
        NSLog(@"Error happened = %@", error);
    }
    
    return self.responseJSONData;
}


@end
