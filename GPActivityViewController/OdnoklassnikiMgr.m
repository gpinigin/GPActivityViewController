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
#import "OdnoklassnikiMgr.h"
#import "AFNetworking.h"
#import "Cocoa+Additions.h"

NSString *const kOKBundleAppID = @"OdnoklassnikiAppID";
NSString *const kOKBundleSecretKey = @"OdnoklassnikiSecretKey";
NSString *const kOKBundleAppKey = @"OdnoklassnikiAppKey";

NSString *const kOKLoginURL = @"http://www.odnoklassniki.ru/oauth/authorize";
NSString *const kOKAccessTokenURL = @"http://api.odnoklassniki.ru/oauth/token.do";
NSString *const kOKAPIEntryPointURL = @"http://api.odnoklassniki.ru/fb.do";

NSString *const kOKTokenKey = @"kOKTokenKey:info";

@interface OdnoklassnikiMgr () {
    NSArray *_permissions;
    
    NSString *_accessToken;
    NSString *_refreshToken;
}

@property (nonatomic, copy) void (^completionBlock)(void);

@end

@implementation OdnoklassnikiMgr

+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    static OdnoklassnikiMgr *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [OdnoklassnikiMgr new];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _applicationId = [[NSBundle mainBundle] objectForInfoDictionaryKey:kOKBundleAppID];
        if (_applicationId == nil) {
            NSLog(@"<%@> not found. Make sure you properly set it in info.plist file", kOKBundleAppID);
        }
        
        _secretKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kOKBundleSecretKey];
        if (_secretKey == nil) {
            NSLog(@"<%@> not found. Make sure you properly set it in info.plist file", kOKBundleSecretKey);
        }
        
        _appKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:kOKBundleAppKey];
        if (_appKey == nil) {
            NSLog(@"<%@> not found. Make sure you properly set it in info.plist file", kOKBundleAppKey);
        }
        
        if (_applicationId) {
            NSString *redirectScheme = [NSString stringWithFormat:@"ok%@://authorize", _applicationId];
            if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:redirectScheme]]) {
                NSLog(@"Your app cannot handle callback scheme. Make sure you properly set supported url scheme in info.plist. Should be ok%@", _applicationId);
            }
        }
    }
    
    return self;
}

- (void)debugOut:(NSString *) fmt, ... {
    if (_debugEnabled) {
        va_list args;
        if (fmt) {
            va_start(args, fmt);
            NSLogv(fmt, args);
            va_end(args);
        }
    }
}

- (NSURL *)odnoklassnikiAppURL {
    return [NSURL URLWithString:@"okauth://authorize"];
}

#pragma mark - access token

- (void)setAccessToken:(NSString *)accessToken {
    _accessToken = accessToken;
    [self setTokenInfo:accessToken forKey:@"accessToken"];
}

- (NSString *)accessToken {
    if (!_accessToken) {
        NSDictionary *tokenInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kOKTokenKey];
        _accessToken = [tokenInfo objectForKey:@"accessToken"];
    }
    
    return _accessToken;
}


- (void)retrieveAccessToken:(NSArray *)permissions completion:(void (^)(void))block {
    BOOL hasApp = [[UIApplication sharedApplication] canOpenURL:[self odnoklassnikiAppURL]];

    // TODO compare permissions to issue new token
    _permissions = permissions;      
    self.completionBlock = block;
    
    NSString *redirectURI = [NSString stringWithFormat:@"ok%@://authorize", _applicationId];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_applicationId forKey:@"client_id"];
    [params setObject:redirectURI forKey:@"redirect_uri"];
    [params setObject:@"code" forKey:@"response_type"];
    if (!hasApp) {
        [params setObject:@"m" forKey:@"layout"];
    }
    
    if (_permissions) {
        [params setObject:[_permissions componentsJoinedByString:@";"] forKey:@"scope"];
    }
    
    NSURL *baseUrl = hasApp? [self odnoklassnikiAppURL]: [NSURL URLWithString:kOKLoginURL];
    NSURL *oauthURL =  [baseUrl serializeURLWithParams:params];
    
    [[UIApplication sharedApplication] openURL:oauthURL];
}

- (void)setRefreshToken:(NSString *)refreshToken {
    _refreshToken = refreshToken;
    [self setTokenInfo:refreshToken forKey:@"refreshToken"];    
}

- (NSString *)refreshToken {
    if (!_refreshToken) {
        NSDictionary *tokenInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kOKTokenKey];
        _refreshToken = [tokenInfo objectForKey:@"refreshToken"];
    }
    
    return _refreshToken;
}

- (void)setTokenType:(NSString *)tokenType {
    [self setTokenInfo:tokenType forKey:@"tokenType"];
}

- (void)setTokenInfo:(NSString *)tokenValue forKey:(NSString *)key {
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    NSDictionary *tokenInfo = [defaults objectForKey:kOKTokenKey];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:tokenInfo];
    [dict setObject:tokenValue forKey:key];
    [defaults setObject:dict forKey:kOKTokenKey];
    [defaults synchronize];
}


#pragma mark - helpers

- (NSString *)signature:(NSDictionary *)params {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];

    NSMutableString *resultString = [[NSMutableString alloc] init];
    for(NSString *key in sortedKeys) {
        [resultString appendFormat:@"%@=%@", key, [params objectForKey:key]];
    }
    
    [resultString appendString:[[NSString stringWithFormat:@"%@%@", [self accessToken], _secretKey] MD5String]];
    return [resultString MD5String];
}

#pragma mark - handle url

- (BOOL)handleOpenURL:(NSURL *)url {
    if (![url.scheme isEqualToString:[NSString stringWithFormat:@"ok%@", _applicationId]]) {
        return NO;
    }
    
    NSCharacterSet *delims = [NSCharacterSet characterSetWithCharactersInString:@"=&"];
    NSArray *parts = [url.query componentsSeparatedByCharactersInSet:delims];
    if (parts.count % 2 == 1) {
        [self debugOut:@"URL redirect address is malformed"];
        return NO;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:parts.count / 2];
    for (NSUInteger index = 0; index < parts.count; index += 2) {
        [params setObject:[parts objectAtIndex:index + 1] forKey:[parts objectAtIndex:index]];
    }
    
    if ([params objectForKey:@"error"]) {
        // TODO handle error
        return YES;    }
    
    NSString *code = [params objectForKey:@"code"];
    [self continueRetrievingAccessToken:code];
    
    return YES;
}

- (void)renewAccessToken:(void (^)())completion {    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setValue:[self refreshToken] forKey:@"refresh_token"];
	[params setValue:@"refresh_token" forKey:@"grant_type"];
	[params setValue:_applicationId forKey:@"client_id"];
	[params setValue:_secretKey forKey:@"client_secret"];
    
    NSURL *baseURL = [NSURL URLWithString:kOKAccessTokenURL];
    NSURL *tokenRequestURL = [baseURL serializeURLWithParams:params];
    NSMutableURLRequest *tokenRequest = [NSMutableURLRequest requestWithURL:baseURL];
    [tokenRequest setHTTPMethod:@"POST"];
    [tokenRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    
    NSString *body = [tokenRequestURL query];
    [tokenRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    typeof(self) __weak weakSelf = self;
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:tokenRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [weakSelf setAccessToken:[JSON objectForKey:@"access_token"]];
        
        if (completion) {
            completion();
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completion) {
            completion();
        }
        
        [self debugOut:@"%@", error];
    }];
    [operation start];
}

- (void)continueRetrievingAccessToken:(NSString *)code {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:code forKey:@"code"];
    
    NSString *redirectURI = [NSString stringWithFormat:@"ok%@://authorize", _applicationId];
    [params setObject:redirectURI forKey:@"redirect_uri"];
    [params setObject:@"authorization_code" forKey:@"grant_type"];    
    [params setObject:_applicationId forKey:@"client_id"];
    [params setObject:_secretKey forKey:@"client_secret"];
    
    NSURL *baseURL = [NSURL URLWithString:kOKAccessTokenURL];
    NSURL *tokenRequestURL = [baseURL serializeURLWithParams:params];
    NSMutableURLRequest *tokenRequest = [NSMutableURLRequest requestWithURL:baseURL];
    [tokenRequest setHTTPMethod:@"POST"];
    [tokenRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];

    NSString *body = [tokenRequestURL query];
    [tokenRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    typeof(self) __weak weakSelf = self;
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:tokenRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [weakSelf setAccessToken:[JSON objectForKey:@"access_token"]];
        [weakSelf setRefreshToken:[JSON objectForKey:@"refresh_token"]];
        [weakSelf setTokenType:[JSON objectForKey:@"token_type"]];

        if (weakSelf.completionBlock) {
            weakSelf.completionBlock();
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (weakSelf.completionBlock) {
            weakSelf.completionBlock();
        }

        [self debugOut:@"%@", error];
    }];
    [operation start];
}

#pragma mark - share

- (void)shareURL:(NSString *)urlString description:(NSString *)description {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:urlString forKey:@"linkUrl"];
    [params setObject:description forKey:@"comment"];
   [params setObject:_appKey forKey:@"application_key"];
    [params setObject:@"share.addLink" forKey:@"method"];
    
    NSString *signature = [self signature:params];
    
    [params setObject:signature forKey:@"sig"];
    [params setObject:[self accessToken] forKey:@"access_token"];
    
    NSURL *requestURL = [[NSURL URLWithString:kOKAPIEntryPointURL] serializeURLWithParams:params];    
    NSMutableURLRequest *shareRequest = [NSMutableURLRequest requestWithURL:requestURL];
    
    typeof(self) __weak weakSelf = self;
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:shareRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        int errorCode = [[JSON objectForKey:@"error_code"] integerValue];
        if (errorCode == 102) {
            [weakSelf renewAccessToken:^() {
                [weakSelf shareURL:urlString description:description];
            }];
        }
        
        [self debugOut:@"%@", JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self debugOut:@"%@", error];
    }];
    [operation start];
}

@end
