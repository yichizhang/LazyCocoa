//
//  NSString+LazyCocoa.h
//  LazyCocoa-MacApp
//
//  Created by Yichi on 28/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LazyCocoa)

- (BOOL)isValidNumber;
- (BOOL)isValidColorCode;

- (BOOL)isMeantToBeFont;
- (BOOL)isMeantToBeColor;
- (BOOL)isMeantToBeNeitherFontOrColor;

@end
