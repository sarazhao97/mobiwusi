//
//  MOSearchHistoryHeader.h
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/19.
//

#import "MOView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MOSearchHistoryHeader : MOView
@property(nonatomic,copy)void(^didSelectHistorySearch)(NSString *text);
@property(nonatomic,copy)void(^didClearHistorySearch)(void);
@end

NS_ASSUME_NONNULL_END
