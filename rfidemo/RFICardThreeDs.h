//
//  RFICard3DS.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 17.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFICardThreeDs : NSObject
{
    NSString * _ACSUrl;
    NSString * _MD;
    NSString * _PaReq;
}

@property (nonatomic, copy) NSString * ACSUrl;
@property (nonatomic, copy) NSString * MD;
@property (nonatomic, copy) NSString * PaReq;

-(id) initWithParams: (NSDictionary *)params;

@end
