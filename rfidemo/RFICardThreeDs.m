//
//  RFICard3DS.m
//  RFI Demo
//
//  Created by Ivan Streltcov on 17.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import "RFICardThreeDs.h"

@implementation RFICardThreeDs

-(id) initWithParams: (NSDictionary *)params {
    
    if(self = [super init]) {
        _ACSUrl = [params objectForKey:@"ACSUrl"];
        _MD = [params objectForKey:@"MD"];
        _PaReq = [params objectForKey:@"PaReq"];
    }
    
    return self;
}
@end
