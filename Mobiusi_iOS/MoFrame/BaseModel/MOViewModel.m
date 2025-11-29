//
//  MOViewModel.m
//  MonkeyTanslate
//
//  Created by x11 on 2024/7/28.
//  Copyright © 2024 yuyun. All rights reserved.
//

#import "MOViewModel.h"

@implementation MOViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {}


#pragma mark - getter setter
- (NSString *)appLanguageCode{
//    _appLanguageCode = QCLocalizedStringFromTable(@"appLanguageCode", @"MessageDisplayKitString", @"app国际化语言代码");
    return @"en";
}

- (void)dealloc {
    DLog(@"%@ ----> dealloc", [self class]);
}
@end
