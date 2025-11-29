//
//  NSObject+KVO.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/2/25.
//

#import "NSObject+KVO.h"



static const char *chnageBlck = "chnageBlck";

@interface NSObject ()
@property(nonatomic,strong)NSMutableArray<NSMapTable *> *changeBlcks;
@end

@implementation NSObject (KVO)

- (void)setChnageBlck:(NSMutableArray *)chnageBlck1 {
    
    objc_setAssociatedObject(self, &chnageBlck, chnageBlck1, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray<NSDictionary *> *)changeBlcks {
    
    NSMutableArray *tmp = objc_getAssociatedObject(self, &chnageBlck);
    if (!tmp) {
        
        objc_setAssociatedObject(self, &chnageBlck, @[].mutableCopy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, &chnageBlck);
}

-(void)observeValueForKeyPath:(NSString *)keyPath chnageBlck:(void(^)(NSDictionary *change,id object))chnageBlck{
    
    
    BOOL  exist = NO;
    for (NSDictionary *item in self.changeBlcks) {
        NSString *itemKeyPath = item.allKeys.firstObject;
        if ([itemKeyPath isEqualToString:keyPath]) {
            exist = YES;
        }
    }
    
    if (exist) {
        return;
    }
    [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    NSMapTable *map = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory capacity:1];
    [map setObject:[chnageBlck copy] forKey:keyPath];
    [self.changeBlcks addObject:map];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    for (NSDictionary *item in self.changeBlcks) {
        
        NSString *itemKeyPath = item.allKeys.firstObject;
        if ([itemKeyPath isEqualToString:keyPath]) {
            void(^itemValue)(NSDictionary *change,id object) = item[itemKeyPath];
            itemValue(change,object);
        }
    }
}
@end
