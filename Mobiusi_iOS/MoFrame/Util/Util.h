
//AtomDay

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Util : NSObject

+ (BOOL)saveNSDocumentDirectory:(NSString *) fileName file:(id)file;

//从本地读取数据
+ (NSDictionary *)getLocalDataDic:(NSString *)fileName;
//从本地读取数据
+ (NSMutableArray *)getLocalDataList:(NSString *)fileName;
//从本地获取模型数组
+ (NSMutableArray *)getLocalDataModelArray:(NSString *)fileName;
//存入数据
+ (void)saveToFile:(NSMutableArray *)dataList withFileName:(NSString *)fileName;
//存入数据
+ (void)saveDicToFile:(NSDictionary *)dataDic withFileName:(NSString *)fileName;
//模型数组存入本地
+ (void)saveToDataModelArrayFile:(NSArray *)modelArray withFileName:(NSString *)fileName;
//存入模型
+ (void)saveToDataModelFile:(id)model withFileName:(NSString *)fileName;
//从本地读取模型
+ (id)getLocalDataModel:(NSString *)fileName;


//时间转换
+ (NSString *)changeDateToMinuteWithLongLongDate:(long long)date timeDiff:(NSString *)timeDiff;
+ (NSString *)changeDateWithLongLongDate:(long long)date;

/** 距离当前时间差转换 */
+ (NSString *)compareCurrentTime:(long long)createTime;

/**
 动态计算Lable尺寸
 @param text label上面显示的text
 @param size label的宽高约束尺寸
 @param font label的字号
 @return 计算出的size
 */
+ (CGSize)calculateLabelSizeWithText:(NSString *)text andMarginSize:(CGSize)size andTextFont:(UIFont *)font;

+ (NSString *)createFolder:(NSString *)folderName;

+ (CGFloat)statusBarHeight;

@end
