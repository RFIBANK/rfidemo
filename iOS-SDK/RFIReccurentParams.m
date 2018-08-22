//
//  RFIReccurentParams.m
//  
//
//  Created by Alexander Nazarov on 8/9/18.
//

#import "RFIReccurentParams.h"

@implementation RFIReccurentParams

- (instancetype)initWithType:(RFIReccurentType)type
                     comment:(NSString *)comment
                         url:(NSString *)url
                     orderId:(NSString *)orderId
                  periodType:(RFIReccurentPeriodType)periodType
{
    self = [super init];
    if (self) {
        self.type = type;
        self.comment = comment;
        self.url = url;
        self.orderId = orderId;
        self.periodType = periodType;
    }
    
    return self;
}

- (NSString *)period
{
    switch (self.periodType) {
        case RFIReccurentPeriodTypeNone: return nil;
        case RFIReccurentPeriodTypeByRequest: return @"byrequest";
    }
}

+ (instancetype)firstWithUrl:(NSString *)url andComment:(NSString *)comment
{
    return [[RFIReccurentParams alloc] initWithType:RFIReccurentTypeFirst
                                            comment:comment
                                                url:url
                                            orderId:nil
                                         periodType:RFIReccurentPeriodTypeByRequest];
}

+ (instancetype)nextWithOrderId:(NSString *)orderId
{
    return [[RFIReccurentParams alloc] initWithType:RFIReccurentTypeNext
                                            comment:nil
                                                url:nil
                                            orderId:orderId
                                         periodType:RFIReccurentPeriodTypeNone];
}

@end
