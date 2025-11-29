//
//  NSString+Encrypt3DESandBase64.h
//
//  Created by Er.Z on 13-12-2.
//

#import <Foundation/Foundation.h>

#define metastar_key @"qz6ZnfpGTl1nvAhAymQoYLCk"
#define metastar_vec @"Itk9OPRn"

@interface NSString (Encrypt3DESandBase64)

- (NSString *)encryptStringWithKey:(NSString*)_encryptKey vec:(NSString *)_encryptVec;
- (NSString *)decryptStringWithKey:(NSString*)_encryptKey vec:(NSString *)_encryptVec;

@end
