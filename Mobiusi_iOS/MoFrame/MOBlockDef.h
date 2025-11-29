//
//  MOBlockDef.h
//  LW_Translate
//
//  Created by x11 on 2023/9/16.
//

#ifndef MOBlockDef_h
#define MOBlockDef_h
typedef void(^MOBlock)(void);
typedef void(^MOFloatBlock)(CGFloat floatValue);
typedef void(^MOStringBlock)(NSString *string);
typedef void(^MODataBlock)(NSData *data);
typedef void(^MOImageBlock)(UIImage *image);
typedef void(^MOObjectBlock)(id obj);
typedef void(^MOArrayBlock)(NSArray *array);
typedef void(^MOMutableArrayBlock)(NSMutableArray *array);
typedef void(^MODictionaryBlock)(NSDictionary *dic);
typedef void(^MOErrorBlock)(NSError *error);
typedef void(^MOIndexBlock)(NSInteger index);
typedef void(^MOBoolBlock)(BOOL boolValue);

#endif /* MOBlockDef_h */
