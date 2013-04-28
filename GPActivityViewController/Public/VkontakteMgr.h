//
//  VkontakteMgr.h
//  Pods
//
//  Created by Gleb on 4/28/13.
//
//

#import <Foundation/Foundation.h>

@interface VkontakteMgr : NSObject

@property (nonatomic, readonly) NSString *applicaitonId;
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *userId;

+ (instancetype)sharedInstance;
- (void)retrieveAccessToken:(NSArray *)permissions completion:(void (^)(BOOL))block;
- (BOOL)handleOpenURL:(NSURL *)url;

- (void)shareText:(NSString *)text image:(UIImage *)image;
- (void)shareText:(NSString *)text;

@end
