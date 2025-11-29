//
//  MOHomeVM.m
//  Mobiusi_iOS
//
//  Created by x11 on 2024/9/11.
//

#import "MOHomeVM.h"


@implementation MOHomeVM

- (void)getUserInfoSuccess:(MODictionaryBlock)success failure:(MOErrorBlock)failure msg:(MOStringBlock)msg loginFail:(MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getUserInfoSuccess:^(NSDictionary *dic) {
        MOUserModel *user = [MOUserModel yy_modelWithJSON:dic];
        [user archivedUserModel];
        success(dic);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}


- (void)getCateOptionSuccess:(nonnull MODictionaryBlock)success failure:(nonnull MOErrorBlock)failure msg:(nonnull MOStringBlock)msg loginFail:(nonnull MOBlock)loginFail {
    [[MONetDataServer sharedMONetDataServer] getCateOptionSuccess:^(NSDictionary *dic) {
        success(dic);
    } failure:^(NSError *error) {
        failure(error);
    } msg:^(NSString *string) {
        msg(string);
    } loginFail:^{
        loginFail();
    }];
}

+(void)getincomeTipWithSuccess:(nonnull MOObjectBlock)success failure:(nullable MOErrorBlock)failure msg:(nullable MOStringBlock)msg loginFail:(nullable MOBlock)loginFail {
    
    [[MONetDataServer sharedMONetDataServer] getincomeTipWithSuccess:^(NSDictionary *dict) {
        if (success) {
            MOIncomeTipModel *model = [MOIncomeTipModel yy_modelWithJSON:dict];
            success(model);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
        
    } msg:^(NSString *string) {
        if (msg) {
            msg(string);
        }
        
    } loginFail:^{
        if (loginFail) {
            loginFail();
        }
        
    }];
}

@end
