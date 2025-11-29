//
//  NSString+Util.m
//  Metronome
//
//  Created by x11 on 2022/9/28.
//

#import "NSString+Util.h"


@implementation NSString (Util)

- (NSString *)urlEncoding {
    NSString *charactersToEscape = @"？！?!@#$^&%*+,:;='\"`<>()[]{}/\\| \n";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}

- (NSString *)afnUrlEncoding {
    NSString * kQCCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    NSString * kQCCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kQCCharactersGeneralDelimitersToEncode stringByAppendingString:kQCCharactersSubDelimitersToEncode]];
    
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;
    
    while (index < self.length) {
        NSUInteger length = MIN(self.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [self substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];
        
        index += range.length;
    }
    return escaped;
}

- (NSString *)encodingUsingUTF8String {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)exchangeNull {
    NSString *resultString = [self stringByReplacingOccurrencesOfString:@"(null)" withString:@""];
    return resultString;
}

- (NSString *)cutLastSymbol{
//    DLog(@"****************************传入的字符串:\n %@\n",str);
    NSString *symbolSet = @"{}<>?,./;:'[]!@$^()=_+！@#¥%…&*（）-=——+，。／；’：“《》？「」【】~～";
    NSString *newStr = self;
    for (NSInteger i = self.length-1; i > 0; i--){
        NSString *lastChar = [self substringWithRange:NSMakeRange(i, 1)];
        if ([lastChar isEqualToString:@" "] || [lastChar isEqualToString:@"\n"] || [symbolSet containsString:lastChar]){
            newStr = [newStr stringByReplacingCharactersInRange:NSMakeRange(newStr.length-1, 1) withString:@""];
        } else {
            break;
        }
    }
//    DLog(@"****************************处理后的的字符串:\n %@\n",newStr);
    return newStr;
}

- (NSString *)cutAllSymbol {
    NSLog(@"*************cutAllSymbol***************传入的字符串:\n %@\n",self);
    if (self.length==0 || !self) {
        return nil;
    }
    
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"[ _`~!@#$%^&*()+=|{}':;',\\[\\].<>/?~！@#￥%……&*（）——+|{}【】‘；：”“’。，、？]|\n|\r|\t"];
    
    NSString *string = [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
//    NSError *error = nil;
//    NSString *pattern = @"[^a-zA-Z0-9\u4e00-\u9fa5]";//正则取反
//    NSRegularExpression *regularExpress = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];//这个正则可以去掉所有特殊字符和标点
//    NSString *string = [regularExpress stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@""];
    
    NSLog(@"**************cutAllSymbol**************处理后的的字符串:\n %@\n",string);
    return string;
}

- (NSString *)cutWhitespace {
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return string;
}

- (BOOL)isExist {
    return self && ![self isEqualToString:@""];
}

- (BOOL)isBlank {
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

- (NSString *)filterHTML {
    NSString *filterStr = self;
    filterStr = [filterStr stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
    filterStr = [filterStr stringByReplacingOccurrencesOfString:@"</p>" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:filterStr];
    NSString *text = nil;
    while([scanner isAtEnd] == NO) {
        [scanner scanUpToString:@"<" intoString:nil];
        [scanner scanUpToString:@">" intoString:&text];
        filterStr = [filterStr stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@"\n"];
    }
//    NSUInteger returnLength = [@"\n" length];
//    NSLog(@"filterStr - **\n**%@**", filterStr);
//    if ([filterStr hasPrefix:@"\n"]) {
//        [filterStr stringByReplacingCharactersInRange:NSMakeRange(0, returnLength) withString:@""];
//    }
//
//    if ([filterStr hasSuffix:@"\n"]) {
//        [filterStr stringByReplacingCharactersInRange:NSMakeRange(filterStr.length-returnLength, returnLength) withString:@""];
//    }

    return filterStr;
}


// 数字汉字转阿拉伯数字
- (NSString *)translateNumber {
    NSString *str = self;

    NSArray *arabic_numerals = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"0",@"00",@"000",@"0000",@"1"];
    NSArray *chinese_numerals = @[@"一",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"零", @"十",@"百",@"千",@"万",@"幺"];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:arabic_numerals forKeys:chinese_numerals];

    NSMutableArray *sums = [NSMutableArray array];

    for (int i = 0; i < str.length; i ++) {
        NSString *substr = [str substringWithRange:NSMakeRange(i, 1)];
        NSString *sum = substr;
        if([chinese_numerals containsObject:substr]){
            //            NSLog(@"=====%@", substr);
            NSString *prefixTen = @"";
            
            if(([substr isEqualToString:@"十"])&& i > 0){
                NSString *nextStr = [str substringWithRange:NSMakeRange(i-1, 1)];
                if(![chinese_numerals containsObject:nextStr]){
                    prefixTen = @"1";
                }
            }
            if(([substr isEqualToString:@"十"])&& i == 0){
               prefixTen = @"1";
            }
            [sums addObject:prefixTen];

            if(([substr isEqualToString:@"十"] || [substr isEqualToString:@"百"] || [substr isEqualToString:@"千"] || [substr isEqualToString:@"万"])&& i < str.length - 1){
                NSString *nextStr = [str substringWithRange:NSMakeRange(i+1, 1)];
                //                NSLog(@"-----%@", nextStr);
                if([chinese_numerals containsObject:nextStr]){
                    continue;
                }
            }
            sum = [dictionary objectForKey:substr];
        }
//        NSLog(@"====%@", sum);
        [sums addObject:sum];
    }

    NSString *sumStr = [sums  componentsJoinedByString:@""];
    return sumStr;
}

- (BOOL)matchRegex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}

// Decimals (小数位数)
- (NSString *)reviseStringWithDecimals:(NSInteger)decimals {
    
    float conversionValue = [self floatValue];
    NSString *floatString;
    if (decimals == 0) {
        floatString = [NSString stringWithFormat:@"%.f", conversionValue];
    } else if (decimals == 1) {
        floatString = [NSString stringWithFormat:@"%.1f", conversionValue];
    } else if (decimals == 2) {
        floatString = [NSString stringWithFormat:@"%.2f", conversionValue];
    } else if (decimals == 3) {
        floatString = [NSString stringWithFormat:@"%.3f", conversionValue];
    } else if (decimals == 4) {
        floatString = [NSString stringWithFormat:@"%.4f", conversionValue];
    } else if (decimals == 5) {
        floatString = [NSString stringWithFormat:@"%.5f", conversionValue];
    } else {
        floatString = [NSString stringWithFormat:@"%f", conversionValue];
    }
    NSString *string = floatString;
    return string;
}

+ (NSString *)stringWithTime:(NSTimeInterval)time {
    
    NSInteger min = time / 60;
    NSInteger second = (NSInteger)time % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)second];
}

- (NSAttributedString *)attributedStringWithLineSpace:(CGFloat)lineSpace {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace; // 调整行间距
    NSRange range = NSMakeRange(0, [self length]);
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
    return attributedString;
}

+ (NSString *)nowDateStr {
    NSDate *nowDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    return [formatter stringFromDate:nowDate];
}

/**
 * 计算字词数
 * @param str 待计算字词数
 * @return 结果
 */
- (int)countWordWithString:(NSString *)str {
    int count = 0;
    
    if(!str.isExist){
        return count;
    }
    
    NSString *regexChinese = @"^[\u4e00-\u9fa5]{1}$";    //汉字正则
    NSString *regexLetter = @"^[a-zA-Z]{1}$";            //字母正则
    NSString *regexSymbol = @"[\\pP\\pZ‘’“”]";            //标点符号
    
    Boolean wordBegin = false;    //单词的临时变量
    for(int i=0;i<str.length;i++) {
        NSString *charString = [str substringWithRange:NSMakeRange(i, 1)];
        if([charString isBlank]
           || [charString matchRegex:regexSymbol]) {
            //空白符
            if(wordBegin) {
                count++;       //单词处理
                wordBegin = false;
            }
            continue;
        } else if ([charString matchRegex:regexChinese]) {
            count++;  //汉字
            continue;
        } else if ([charString matchRegex:regexLetter]) {
            wordBegin = true;
        } else {
            count++;    //其他符号
        }
    }
    if(wordBegin) {
        count++;
    }
    return count;
}
@end
