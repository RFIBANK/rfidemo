//
//  RFIConnectionProfile.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 16.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFIConnectionProfile : NSObject

-(NSString *) baseUrl;
-(NSString *) cardTokenUrl;
-(NSString *) cardTokenTestUrl;

@end
