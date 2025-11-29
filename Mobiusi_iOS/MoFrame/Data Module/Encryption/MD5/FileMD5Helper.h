//
//  FileMD5Helper.h
//  YuYun
//
//  Created by x11 on 2023/6/21.
//  Copyright © 2023年 yu yun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileMD5Helper : NSObject

+ (NSString*)getFileMD5WithPath:(NSString*)path;

@end
