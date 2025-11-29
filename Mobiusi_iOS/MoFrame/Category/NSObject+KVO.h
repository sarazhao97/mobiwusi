//
//  NSObject+KVO.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVO)
-(void)observeValueForKeyPath:(NSString *)keyPath chnageBlck:(void(^)(NSDictionary *change,id object))chnageBlck;
@end

NS_ASSUME_NONNULL_END
