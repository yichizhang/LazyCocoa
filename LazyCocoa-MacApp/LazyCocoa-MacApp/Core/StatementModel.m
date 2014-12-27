/*
 
 Copyright (c) 2014 Yichi Zhang
 https://github.com/yichizhang
 zhang-yi-chi@hotmail.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "StatementModel.h"
#import "LazyCocoa_MacApp-Swift.h"

#define HASH_STRING @"#"
#define DOUBLE_QUOTE_CHAR '"'
#define DOUBLE_QUOTE_STRING @"\""
#define SPACE_STRING @" "

/*
@interface NSString (LazyCocoa)

- (BOOL)isValidNumber;
- (BOOL)isValidColorCode;

@end
*/

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

@end

@implementation StatementModel

- (instancetype)initWithString:(NSString*)string
{
	self = [super init];
	if (self) {
		
		self.statementString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		
		NSString * firstNameString, * secondNameString, * colorCodeString, * fontNameString, * fontSizeString;
		
		NSScanner *scanner = [NSScanner scannerWithString:self.statementString];
		
		NSString *resultString;
		
		while (scanner.scanLocation < self.statementString.length) {
			
			unichar character = [self.statementString characterAtIndex:scanner.scanLocation];
			
			if (character == DOUBLE_QUOTE_CHAR) {
				
				scanner.scanLocation ++;
				[scanner scanUpToString:DOUBLE_QUOTE_STRING intoString:&resultString];
				
				fontNameString = resultString;
			}else{
				
				[scanner scanUpToString:SPACE_STRING intoString:&resultString];
				
				if ([resultString isValidNumber]) {
					fontSizeString = resultString;
				}else if ([resultString isValidColorCode]) {
					colorCodeString = resultString;
				}else {
					if (!firstNameString) {
						firstNameString = resultString;
					}else {
						secondNameString = resultString;
					}
				}
				
			}
			
			if (scanner.scanLocation < self.statementString.length) {
				scanner.scanLocation ++;
			}
		}
//
//
		
		_identifier = firstNameString;
		
		if ( firstNameString && colorCodeString ) {
			
			self.color = [[DetailSpecifiedColorModel alloc] initWithMethodName:firstNameString colorHexString:colorCodeString];
			
		}else if ( firstNameString && secondNameString ) {
			
			self.color = [[ReferToOtherColorModel alloc] initWithMethodName:firstNameString methodNameToCall:secondNameString];
			
		}
		
		if ( firstNameString && fontNameString && fontSizeString ) {
			
			self.font = [[DetailSpecifiedFontModel alloc] initWithMethodName:firstNameString fontName:fontNameString size:[fontSizeString floatValue]];
			
		}else if ( firstNameString && secondNameString ) {
			
			self.font = [[ReferToOtherFontModel alloc] initWithMethodName:firstNameString methodNameToCall:secondNameString];
			
		}
	}
	return self;
}

@end
