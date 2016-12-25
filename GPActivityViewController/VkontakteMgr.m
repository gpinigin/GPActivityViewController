//
// Copyright (c) 2013-2014 Gleb Pinigin (https://github.com/gpinigin)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "VkontakteMgr.h"
#import "Cocoa+Additions.h"
#import "AFNetworking.h"

NSString *const kVKBundleAppID = @"VKontakteAppID";
NSString *const kVKTokenKeyInfo = @"kVKTokenKey:info";

NSString *const kVKLoginURL = @"https://oauth.vk.com/authorize";
NSString *const kVKEntryPoint = @"https://api.vk.com/method/";

@interface VkontakteMgr () {
    NSArray *_permissions;
    NSString *_accessToken;
    NSString *_userId;
}

@property (nonatomic, copy) void (^authCompletion)(BOOL);

@end 

@implementation VkontakteMgr

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VkontakteMgr *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [VkontakteMgr new];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _applicationId = [[NSBundle mainBundle] objectForInfoDictionaryKey:kVKBundleAppID];
        if (_applicationId == nil) {
            NSLog(@"<%@> not found. Make sure you properly set it in info.plist file", kVKBundleAppID);
        }

        if (_applicationId) {
            NSString *redirectScheme = [NSString stringWithFormat:@"vk%@://", _applicationId];
            if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:redirectScheme]]) {
                NSLog(@"Your app cannot handle callback scheme. Make sure you properly set supported url scheme in info.plist. Should be vk%@:", _applicationId);
            }
        }
    }

    return self;
}

#pragma mark - official application

- (NSURL *)applicationURL {
    return [NSURL URLWithString:@"vkauth://authorize"];
}

#pragma mark -

- (void)retrieveAccessToken:(NSArray *)permissions completion:(void (^)(BOOL))completion {
    self.authCompletion = completion;
    BOOL hasApp = [[UIApplication sharedApplication] canOpenURL:[self applicationURL]];
    _permissions = permissions;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_applicationId forKey:@"client_id"];
    if (permissions) {
        [params setObject:permissions forKey:@"scope"];
    }

    if (!hasApp) {
        NSString *redirectURI = [NSString stringWithFormat:@"vk%@://authorize", _applicationId];
        [params setObject:redirectURI forKey:@"redirect_uri"];
        [params setObject:@"mobile" forKey:@"display"];
        [params setObject:@"token" forKey:@"response_type"];
    }

    NSURL *baseURL = hasApp? [self applicationURL]: [NSURL URLWithString:kVKLoginURL];
    NSURL *tokenRequestURL = [baseURL serializeURLWithParams:params];

    [[UIApplication sharedApplication] openURL:tokenRequestURL];
}

#pragma mark - handle url

- (BOOL)handleOpenURL:(NSURL *)url {
    if (![url.scheme isEqualToString:[NSString stringWithFormat:@"vk%@", _applicationId]]) {
        return NO;
    }

    NSRange diesRange = [url.absoluteString rangeOfString:@"#"];
    if (diesRange.location == NSNotFound) {
        return NO;
    }

    NSCharacterSet *delims = [NSCharacterSet characterSetWithCharactersInString:@"=&"];
    NSString *query = [url.absoluteString substringFromIndex:diesRange.location + 1];
    NSArray *parts = [query componentsSeparatedByCharactersInSet:delims];
    if (parts.count % 2 == 1) {
        return NO;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:parts.count / 2];
    for (NSUInteger index = 0; index < parts.count; index += 2) {
        [params setObject:[parts objectAtIndex:index + 1] forKey:[parts objectAtIndex:index]];
    }

    if ([params objectForKey:@"error"]) {
        // TODO handle error
    } else {
        NSString *token = [params objectForKey:@"access_token"];
        NSString *userId = [params objectForKey:@"user_id"];
        [self setAccessToken:token];
        [self setUserId:userId];

        if (_authCompletion)
            _authCompletion(YES);
    }

    return YES;
}

#pragma mark - token info 

- (NSString *)accessToken {
    if (!_accessToken) {
        NSDictionary *tokenInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kVKTokenKeyInfo];
        _accessToken = [tokenInfo objectForKey:@"accessToken"];
    }
    
    return _accessToken;
}

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self setTokenInfo:_accessToken forKey:@"accessToken"];
}

- (NSString *)userId {
    if (!_userId) {
        NSDictionary *tokenInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kVKTokenKeyInfo];
        _userId = [tokenInfo objectForKey:@"userId"];
    }
    
    return _userId;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
    [self setTokenInfo:userId forKey:@"userId"];
}

- (void)setTokenInfo:(NSString *)tokenValue forKey:(NSString *)key {
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    NSDictionary *tokenInfo = [defaults objectForKey:kVKTokenKeyInfo];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:tokenInfo];
    [dict setObject:tokenValue forKey:key];
    [defaults setObject:dict forKey:kVKTokenKeyInfo];
    [defaults synchronize];
}

#pragma mark - helpers

- (NSURL *)requestURLWithMethod:(NSString *)methodName {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kVKEntryPoint, methodName]];
}

#pragma mark - VK sharing


- (void)requestPhotoUploadURLWithSuccess:(void (^)(NSString *uploadURL))success {
    NSDictionary *params = @{@"access_token":self.accessToken,
                             @"owner_id":self.userId};
    
    NSURL *requestURL = [[self requestURLWithMethod:@"photos.getWallUploadServer"] serializeURLWithParams:params];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success) {
            success([[JSON objectForKey:@"response"] objectForKey:@"upload_url"]);
        }
    } failure:nil];
    [operation start];
}

- (void)uploadImage:(UIImage *)image toURL:(NSString *)urlString success:(void (^)(NSString *hash, NSString *photo, NSString *server))success {
    
    NSURL *url = [NSURL URLWithString:urlString];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75f);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"" parameters:nil
                                                    constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
                                                        [formData appendPartWithFileData:imageData name:@"photo" fileName:@"photo.jpg" mimeType:@"image/jpg"];
                                                    }];
    
    void (^parseJSON)(id JSON) = ^(id JSON){
        if (success)
            success([JSON objectForKey:@"hash"], [JSON objectForKey:@"photo"], [JSON objectForKey:@"server"]);
    };
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        parseJSON(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        parseJSON(JSON);
    }];
    [operation start];
}

- (void)saveImageToWallWithHash:(NSString *)hash photo:(NSString *)photo server:(NSString *)server success:(void (^)(NSString *wallPhotoId))success {
    NSDictionary *params = @{@"access_token":self.accessToken,
                             @"owner_id":self.userId,
                             @"server":server,
                             @"photo":photo,
                             @"hash":hash};
    
    NSURL *requestURL = [[self requestURLWithMethod:@"photos.saveWallPhoto"] serializeURLWithParams:params];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success)
            success([[[JSON objectForKey:@"response"] objectAtIndex:0] objectForKey:@"id"]);
    } failure:nil];
    [operation start];
}

- (void)shareOnWall:(NSString *)text photoId:(NSString *)wallPhotoId completion:(void (^)(void))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.accessToken forKey:@"access_token"];
    [params setObject:self.userId forKey:@"owner_id"];
    [params setObject:text forKey:@"message"];
    
    if (wallPhotoId) {
        [params setObject:wallPhotoId forKey:@"attachment"];
    }
    
    NSURL *requestURL = [[self requestURLWithMethod:@"wall.post"] serializeURLWithParams:params];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestURL];    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (completion)
            completion();
    } failure:nil];
    [operation start];
}

- (void)shareText:(NSString *)text image:(UIImage *)image {
    
    typeof(self) __weak weakSelf = self;
    [self requestPhotoUploadURLWithSuccess:^(NSString *uploadURL) {
        [weakSelf uploadImage:image toURL:uploadURL success:^(NSString *hash, NSString *photo, NSString *server) {
            [weakSelf saveImageToWallWithHash:hash photo:photo server:server success:^(NSString *wallPhotoId) {
                [weakSelf shareOnWall:text photoId:wallPhotoId completion:nil];
            }];
        }];
    }];
}

- (void)shareText:(NSString *)text {
    [self shareOnWall:text photoId:nil completion:nil];
}

@end
