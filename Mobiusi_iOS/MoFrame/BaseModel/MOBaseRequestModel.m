//
//  MOBaseRequestModel.m
//  Mobiusi_iOS
//
//  Created by Mac on 2025/7/7.
//

#import "MOBaseRequestModel.h"

@implementation MOBaseRequestModel


+ (nullable NSArray<NSString *> *)modelPropertyBlacklist {
	
	return @[@"hostRelativeUrl",@"responseClass"];
}


-(void)startRequestWithComplete:(void(^)(NSString * _Nullable errorMsg,id _Nullable responseModel))complete{
	
	NSString *url = [NSString stringWithFormat:@"%@/%@", API_HOST,self.hostRelativeUrl];
	MONetDataServer *server = [MONetDataServer sharedMONetDataServer];
	NSDictionary *dict = [self yy_modelToJSONObject];
	[server PostWithUrl:url paraDict:dict success:^(NSDictionary *dic) {
		NSDictionary *data =  dic[@"data"];
		if (self.responseClass) {
			if ([data isKindOfClass:[NSArray class]]) {
				NSArray *dataModelClass =  [NSArray yy_modelArrayWithClass:self.responseClass json:data];
				complete(nil,dataModelClass);
				return;
			}
			
			NSObject *dataModelClass =  [self.responseClass yy_modelWithJSON:data];
			complete(nil,dataModelClass);
			return;
		}
		
		complete(nil,data);
		
	} failure:^(NSError *error) {
		complete(error.localizedDescription,nil);
	} msg:^(NSString *string) {
		complete(string,nil);
	} loginFail:^{
		complete(@"loginFail",nil);
	}];
}
@end
