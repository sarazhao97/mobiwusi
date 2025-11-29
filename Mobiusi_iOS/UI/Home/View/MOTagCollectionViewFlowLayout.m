//
//  MOTagCollectionViewFlowLayout.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/12/12.
//

#import "MOTagCollectionViewFlowLayout.h"

@implementation MOTagCollectionViewFlowLayout

//- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
//    
//    for (UICollectionViewLayoutAttributes *attribute in attributes) {
//        if (attribute.representedElementCategory == UICollectionElementCategoryCell) {
//            NSInteger section = attribute.indexPath.section;
//            CGFloat minimumSpacing = self.minimumInteritemSpacing;
//            
//            // 对每个item进行位置调整，确保间距为固定值
//            if (attribute.indexPath.item > 0) {
//                UICollectionViewLayoutAttributes *previousItem = attributes[attribute.indexPath.item - 1];
//                CGFloat previousMaxY = CGRectGetMaxY(previousItem.frame);
//                CGRect frame = attribute.frame;
//                frame.origin.y = previousMaxY + minimumSpacing;  // 设置纵向排列，间距固定为minimumSpacing
//                attribute.frame = frame;
//            }
//        }
//    }
//    
//    return attributes;
//}

@end
