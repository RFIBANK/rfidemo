//
//  RFIHelpers.h
//  RFI Demo
//
//  Created by Ivan Streltcov on 14.10.16.
//  Copyright © 2016 RFI BANK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFIHelpers : NSObject

@end

@interface NSString (RFIHelpers)
- (NSString *) md5;
@end

@interface NSData (RFIHelpers)
- (NSString*)md5;
@end


