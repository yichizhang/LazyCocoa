//
//  NSString+LazyCocoa.m
//  LazyCocoa-MacApp
//
//  Created by Yichi on 28/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

#import "Base.h"
#import "NSString+LazyCocoa.h"

@implementation NSString (LazyCocoa)

- (BOOL)isValidNumber{
	
	NSMutableCharacterSet* set = [[[NSCharacterSet decimalDigitCharacterSet] invertedSet] mutableCopy];
	[set removeCharactersInString:@"."];
	NSRange range = [self rangeOfCharacterFromSet: set];
	return range.location == NSNotFound;
}

- (BOOL)isValidColorCode{
	
	return [self hasPrefix:HASH_STRING];
}

- (BOOL)isMeantToBeFont{
	
	return [self hasSuffix:FONT_SUFFIX];
}

- (BOOL)isMeantToBeColor{
	
	return [self hasSuffix:COLOR_SUFFIX];
}

- (BOOL)isMeantToBeNeitherFontOrColor{
	
	return !([self isMeantToBeFont] && [self isMeantToBeColor]);
}

@end

