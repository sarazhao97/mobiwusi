#import "Util.h"
#import "NSDictionary+Conversion.h"

@implementation Util


+ (BOOL)saveNSDocumentDirectory:(NSString *) fileName file:(id)file{
    BOOL flag=NO;
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray  *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *ruleFilePath = [NSString stringWithFormat:@"%@/%@",documentDirectory,fileName]; //rules.plist
    
    [fileManager removeItemAtPath:ruleFilePath error:nil];
    flag=[file writeToFile:ruleFilePath atomically:YES];
    return flag;
}

//存入数据
+ (void)saveToFile:(NSMutableArray *)dataList withFileName:(NSString *)fileName
{
    // save refreshed data.
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    [dataList writeToFile:path atomically:YES];
}

//存入数据
+ (void)saveDicToFile:(NSDictionary *)dataDic withFileName:(NSString *)fileName
{
    // save refreshed data.
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *vdArchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [vdArchiver encodeObject:dataDic forKey:fileName];
    [vdArchiver finishEncoding];
    [data writeToFile:path atomically:YES];
    //DLog(@"本地存储数据%@ path = %@ ",dataDic, path);
    //    [dataDic writeToFile:path atomically:YES];
}

//存入模型数据
+ (void)saveToDataModelArrayFile:(NSArray *)modelArray withFileName:(NSString *)fileName
{
    // save refreshed data.
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:modelArray];
    [data writeToFile:path atomically:YES];
}

//存入模型
+ (void)saveToDataModelFile:(id)model withFileName:(NSString *)fileName
{
    // save refreshed data.
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:model];
    [data writeToFile:path atomically:YES];
}


//从本地读取模型数组
+ (NSMutableArray *)getLocalDataModelArray:(NSString *)fileName
{
    NSData *data;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	{
        data = [[NSData alloc]initWithContentsOfFile:path];
    }
    NSMutableArray *mutArray = [[NSMutableArray alloc]init];
    NSArray *tempArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    DLog(@"%@",tempArr);
    if (tempArr.count>0) {
        [mutArray addObjectsFromArray:tempArr];
    }
    return mutArray;
}

//从本地读取模型
+ (id)getLocalDataModel:(NSString *)fileName
{
    NSData *data;
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	{
        data = [[NSData alloc]initWithContentsOfFile:path];
    }
    DLog(@"%@",path);
    id model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return model;
}

//从本地读取数据
+ (NSDictionary *)getLocalDataDic:(NSString *)fileName
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	{
//        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:path];
//        DLog(@"本地读取数据字典%@,名称%@",dic,fileName);
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *vdUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        NSDictionary *dataDic = [vdUnarchiver decodeObjectForKey:fileName];
        //        TRACE(@"本地读取数据字典%@,名称%@",dataDic,fileName);
        [vdUnarchiver finishDecoding];
        return dataDic;
        //[theArray addObjectsFromArray:newsList];
    }
    return nil;
}

//从本地读取数据
+ (NSMutableArray *)getLocalDataList:(NSString *)fileName
{
    NSMutableArray *theArray =[NSMutableArray arrayWithCapacity:20];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])	{
        NSMutableArray *newsList = [[NSMutableArray alloc] initWithContentsOfFile:path];
//        DLog(@"本地读取数据%@",newsList);
        for (NSDictionary *newsDic in newsList) {
            [theArray addObject:newsDic];
        }
        //[theArray addObjectsFromArray:newsList];
    }
    return theArray;
}

+ (NSString *)changeDateToMinuteWithLongLongDate:(long long)date timeDiff:(NSString *)timeDiff {
    
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    /** 设置时区 */
    NSString * name = [NSString stringWithFormat:@"GMT%@",timeDiff];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:name];
    [dateFormat setTimeZone:timeZone];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *timeDateString = [dateFormat stringFromDate:timeDate];
    if ([timeDateString hasSuffix:@"00:00"]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        
        /** 设置时区 */
        [dateFormat setTimeZone:timeZone];
        
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *timeDateString = [dateFormat stringFromDate:timeDate];
        return timeDateString;
    }
    
    return timeDateString;
}

+ (NSString *)changeDateWithLongLongDate:(long long)date{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MM-dd HH:mm"];
    [dateFormat setDateFormat:@"MM-dd"];
    NSString *timeDateString = [dateFormat stringFromDate:timeDate];
    return timeDateString;
}

/** 距离当前时间差转换 */
+ (NSString *)compareCurrentTime:(long long)createTime {
    // 获取当前时时间戳 1466386762.345715 十位整数 6位小数
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    // 创建歌曲时间戳(后台返回的时间 一般是13位数字)
    createTime = createTime/1000;
    // 时间差
    NSTimeInterval time = currentTime - createTime;
    // 秒转秒
    NSInteger second = time;
    if (second < 60) {
        return @"刚刚";
    }
    // 秒转分钟
    NSInteger minute = time/60;
    if (minute < 60) {
        return [NSString stringWithFormat:@"%ld%@", (long)minute, @"分钟前"];
    }
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours < 24) {
        return [NSString stringWithFormat:@"%ld%@",(long)hours, @"小时前"];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 30) {
        return [NSString stringWithFormat:@"%ld%@",(long)days, @"天前"];
    }
    //秒转月
    NSInteger months = time/3600/24/30;
    if (months < 12) {
        return [NSString stringWithFormat:@"%ld%@",(long)months, @"月前"];
    }
    //秒转年
    NSInteger years = time/3600/24/30/12;
    return [NSString stringWithFormat:@"%ld%@",(long)years, @"年前"];
}

/**
 动态计算Lable尺寸
 
 @param text label上面显示的text
 @param size label的宽高约束尺寸
 @param font label的字号
 @return 计算出的size
 */
+ (CGSize)calculateLabelSizeWithText:(NSString *)text andMarginSize:(CGSize)size andTextFont:(UIFont *)font
{
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    CGSize actualsize = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:tdic context:nil].size;
    return actualsize;
}
+ (NSString *)createFolder:(NSString *)folderName {
    //创建文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //获取Caches路径,括号中属性为当前应用程序独享
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES);
    NSString *cachesDirectory = [directoryPaths objectAtIndex:0];
    //定义记录文件全名以及路径的字符串filePath
    NSString *foderPath = [cachesDirectory stringByAppendingPathComponent:folderName];
    //查找文件，如果不存在，就创建一个文件
    if (![fileManager fileExistsAtPath:foderPath]) {
        [fileManager createDirectoryAtPath:foderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return foderPath;
}

+ (CGFloat)statusBarHeight {
    if (@available(iOS 13.0, *)) {
        return [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager.statusBarFrame.size.height;
    }
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
