//
//  RFICardTokenResponse.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 17.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFICardTokenResponse.h"

@implementation RFICardTokenResponse

-(id) initWithRequest: (NSDictionary *)cardTokenRequest {
    
    _status = [cardTokenRequest objectForKey:@"status"];

    //если получили ошибки
    if([_status isEqualToString:@"error"]) {
        _hasErrors = (BOOL *) YES;
        _message = [cardTokenRequest objectForKey:@"message"];
        _errors = [cardTokenRequest objectForKey:@"errors"];
    }
    
    //если получили токен
    if([_status isEqualToString:@"success"]) {
        _token = [cardTokenRequest objectForKey:@"token"];
    }
    
//    for (id key in cardTokenRequest) {
//        
//        id object = [cardTokenRequest objectForKey:key];
//        
//        if([object isKindOfClass:[NSDictionary class]]) {
//            
//            for (id key2 in object)  {
//                id object2 = [object objectForKey:key2];
//                NSLog(@"%@-- %@", key2, object2[0]);
//            }
//        } else {
//            NSLog(@"%@: %@", key, object);
//        }
//    }
    
    return self;
}

@end
