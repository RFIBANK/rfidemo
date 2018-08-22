//
//  RFIReccurentParams.h
//  
//
//  Created by Alexander Nazarov on 8/9/18.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RFIReccurentType) {
    RFIReccurentTypeFirst = 0,
    RFIReccurentTypeNext
};

typedef NS_ENUM(NSUInteger, RFIReccurentPeriodType) {
    RFIReccurentPeriodTypeNone = 0,
    RFIReccurentPeriodTypeByRequest
};

@interface RFIReccurentParams : NSObject

@property (nonatomic) RFIReccurentType type;
@property (nonatomic) RFIReccurentPeriodType periodType;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *orderId;
@property (nonatomic, copy, readonly) NSString *period;

+ (instancetype)firstWithUrl:(NSString *)url andComment:(NSString *)comment;
+ (instancetype)nextWithOrderId:(NSString *)orderId;

@end
