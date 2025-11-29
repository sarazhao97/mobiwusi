//
//  NSString+MobiusiTool.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/20.
//

#import "NSString+MobiusiTool.h"

@implementation NSString (MobiusiTool)
+(NSString *)numberOfPeopleToStringWithUnit:(NSInteger)numberOfPeople {
    if (numberOfPeople < 10000) {
        
        return [NSString stringWithFormat:@"%ld",(long)numberOfPeople];
    }
    if (numberOfPeople < 10000000) {
        
        return [NSString stringWithFormat:@"%.1fw",numberOfPeople/10000000.0];
    }
    
    return [NSString stringWithFormat:@"%.1f亿",numberOfPeople/100000000.0];
}

- (BOOL)isRegisterPwd{
    NSString *rule1 = @"^.{6,16}$";
    NSPredicate *pred1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule1];
    BOOL  numValue1= [pred1 evaluateWithObject:self];
    NSString *rule2 = @"(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[!@#$%^&*(),.?\":{}|<>]).+";
    NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",rule2];
    BOOL  numValue2= [pred2 evaluateWithObject:self];
    
    
    return numValue1&&numValue2;
}


-(NSString *)phoneNumberMask {
    if (self.length == 0) {
        return self;
    }
    unsigned int plaintextLength = self.length/2;
    unsigned int headDisplayCount = plaintextLength/2;
    unsigned int maskLength = self.length - 2 * headDisplayCount;
    
    NSMutableString *newStr = [NSMutableString new];
    for (int i  = 0; i < self.length; i++) {
        NSString *character = [self substringWithRange:NSMakeRange(i, 1)];
        if (i <= headDisplayCount) {
            [newStr appendString:character];
            continue;
        }
        
        if (i > headDisplayCount && i< headDisplayCount+maskLength - 1) {
            [newStr appendString:@"*"];
            continue;
        }
        
        if (character.length > 0) {
            [newStr appendString:character];
        }
        

    }
    
    return  newStr;
    
}


+ (NSString *)mimeTypeForExtension:(NSString *)fileExtension {
    // 处理 iOS 14+ 的情况，使用 UTType
    if (@available(iOS 14.0, *)) {
        UTType *utType = [UTType typeWithFilenameExtension:fileExtension];
        if (utType) {
            return utType.preferredMIMEType ?: @"application/octet-stream";
        }
    }
    
    // 旧版系统使用硬编码映射表
    NSDictionary *types = @{
        // 图片格式
        @"jpg": @"image/jpeg",
        @"jpeg": @"image/jpeg",
        @"png": @"image/png",
        @"gif": @"image/gif",
        @"bmp": @"image/bmp",
        @"tiff": @"image/tiff",
        @"tif": @"image/tiff",
        @"webp": @"image/webp",
        @"svg": @"image/svg+xml",
        @"ico": @"image/x-icon",
        @"heic": @"image/heic",
        @"heif": @"image/heif",
        
        // 文档格式
        @"pdf": @"application/pdf",
        @"txt": @"text/plain",
        @"rtf": @"application/rtf",
        @"doc": @"application/msword",
        @"docx": @"application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        @"xls": @"application/vnd.ms-excel",
        @"xlsx": @"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        @"ppt": @"application/vnd.ms-powerpoint",
        @"pptx": @"application/vnd.openxmlformats-officedocument.presentationml.presentation",
        @"odt": @"application/vnd.oasis.opendocument.text",
        @"ods": @"application/vnd.oasis.opendocument.spreadsheet",
        
        // 音频格式
        @"mp3": @"audio/mpeg",
        @"wav": @"audio/wav",
        @"wma": @"audio/x-ms-wma",
        @"aac": @"audio/aac",
        @"ogg": @"audio/ogg",
        @"flac": @"audio/flac",
        @"m4a": @"audio/mp4",
        
        // 视频格式
        @"mp4": @"video/mp4",
        @"mov": @"video/quicktime",
        @"avi": @"video/x-msvideo",
        @"wmv": @"video/x-ms-wmv",
        @"mkv": @"video/x-matroska",
        @"flv": @"video/x-flv",
        @"webm": @"video/webm",
        @"3gp": @"video/3gpp",
        
        // 压缩文件
        @"zip": @"application/zip",
        @"rar": @"application/x-rar-compressed",
        @"7z": @"application/x-7z-compressed",
        @"gz": @"application/gzip",
        @"tar": @"application/x-tar",
        @"bz2": @"application/x-bzip2",
        
        // 网页相关
        @"html": @"text/html",
        @"htm": @"text/html",
        @"css": @"text/css",
        @"js": @"application/javascript",
        @"json": @"application/json",
        @"xml": @"application/xml",
        @"xhtml": @"application/xhtml+xml",
        @"php": @"application/x-httpd-php",
        
        // 字体
        @"ttf": @"font/ttf",
        @"otf": @"font/otf",
        @"woff": @"font/woff",
        @"woff2": @"font/woff2",
        @"eot": @"application/vnd.ms-fontobject",
        
        // 其他
        @"apk": @"application/vnd.android.package-archive",
        @"ipa": @"application/octet-stream",
        @"exe": @"application/x-msdownload",
        @"dll": @"application/x-msdownload",
        @"jsonld": @"application/ld+json",
        @"csv": @"text/csv",
        @"ics": @"text/calendar",
        @"md": @"text/markdown",
        @"sqlite": @"application/x-sqlite3",
        @"webmanifest": @"application/manifest+json",
        @"wasm": @"application/wasm",
        @"bin": @"application/octet-stream",
        @"iso": @"application/x-iso9660-image"
    };
    
    // 返回映射的 MIME 类型，默认使用 application/octet-stream
    return types[[fileExtension lowercaseString]] ?: @"application/octet-stream";
}
@end
