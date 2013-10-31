//
//  VZM.m
//  VZ
//
//  Created by Travis on 13-10-20.
//  Copyright (c) 2013年 Plumn LLC. All rights reserved.
//

#import "VZM.h"
#import <AVOSCloud/AFJSONRequestOperation.h>
#import <AVOSCloud/AFHTTPClient.h>

@implementation VZM
+(VZM*)shared{
    static VZM *_vzm_=Nil;
    if (_vzm_==Nil) {
        _vzm_=[VZM new];
    }
    
    return _vzm_;
}

- (id)init
{
    self = [super init];
    if (self) {
        [VZPost registerSubclass];
        [VZUser registerSubclass];
        
        AFHTTPClient *client=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"vz..avosapps.com"]];
        self.client=client;
    }
    return self;
}

@end




@implementation VZUser
@dynamic avatar;
+ (NSString *)parseClassName {
    return @"_User";
}

-(NSString*)wbid{
    return [self valueForKeyPath:@"authData.weibo.uid"];
}

-(void)findMyFriendOnWeibo:(AVArrayResultBlock)callback{
    NSString *uid=[[self objectForKey:@"authData"] valueForKeyPath:@"weibo.uid"];
    NSString *token=[[self objectForKey:@"authData"] valueForKeyPath:@"weibo.access_token"];
    NSString *url=[NSString stringWithFormat:@"https://api.weibo.com/2/friendships/friends/ids.json?uid=%@&access_token=%@",uid,token];
    NSURLRequest *req=[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    AFJSONRequestOperation *opt=[AFJSONRequestOperation JSONRequestOperationWithRequest:req success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *arr= JSON[@"ids"];
        if (arr) {
            AVQuery *q=[VZUser query];
            [q whereKey:@"authData.weibo.uid" containedIn:arr];
            
            [q findObjectsInBackgroundWithBlock:callback];
        }else{
            callback(Nil,Nil);
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        callback(Nil,error);
    }];
    
    [model.client enqueueHTTPRequestOperation:opt];
    
}

@end