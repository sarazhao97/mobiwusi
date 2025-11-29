

#import <Foundation/Foundation.h>

@interface NSDictionary (Conversion)

//将NSDictionary中的Null类型的项目转化成@""
+ (NSDictionary *)nullDic:(NSDictionary *)myDic;

//将NSDictionary中的Null类型的项目转化成@""
+ (NSArray *)nullArr:(NSArray *)myArr;

//将NSString类型的原路返回
+ (NSString *)stringToString:(NSString *)string;

//将Null类型的项目转化成@""
+ (NSString *)nullToString;

//类型识别:将所有的NSNull类型转化成@""
+ (id)exchangeNull:(id)myObj;

@end
