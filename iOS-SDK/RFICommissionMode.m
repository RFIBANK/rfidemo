//
//  RFICommissionMode.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 18.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFICommissionMode.h"

static NSString * const PARTNER = @"partner";
static NSString * const ABONENT = @"abonent";

@implementation RFICommissionMode

-(NSString *) commissionPartner {
    return PARTNER;
}
-(NSString *) commissionAbonent {
    return ABONENT;
}

@end
