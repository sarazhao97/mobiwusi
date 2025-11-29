//
//  NSString+Util.h
//  Metronome
//
//  Created by x11 on 2022/9/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Util)

- (NSString *)urlEncoding;

- (NSString *)afnUrlEncoding;

- (NSString *)encodingUsingUTF8String;

- (NSString *)exchangeNull;

- (NSString *)cutLastSymbol;

- (NSString *)cutAllSymbol;

- (NSString *)cutWhitespace;

- (NSString *)filterHTML;

// 数字汉字转阿拉伯数字
- (NSString *)translateNumber;

- (BOOL)isExist;

- (BOOL)isBlank;

- (BOOL)matchRegex:(NSString *)regex;

// Decimals (小数位数)
- (NSString *)reviseStringWithDecimals:(NSInteger)decimals;

+ (NSString *)stringWithTime:(NSTimeInterval)time;

+ (NSString *)nowDateStr;

- (NSAttributedString *)attributedStringWithLineSpace:(CGFloat)lineSpace;

@end

NS_ASSUME_NONNULL_END
