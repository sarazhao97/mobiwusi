//
//  MOViewModel.h
//  MonkeyTanslate
//
//  Created by x11 on 2024/7/28.
//  Copyright © 2024 yuyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MOViewModel : NSObject {
    
@protected
    NSString *_appLanguageCode;
}

@property (nonatomic, copy) NSString *appLanguageCode;


- (void)initialize;

@end

NS_ASSUME_NONNULL_END
