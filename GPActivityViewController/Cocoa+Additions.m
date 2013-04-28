//
//  Cocoa+Additions.m
//  Pods
//
//  Created by Gleb on 4/28/13.
//
//

#import "Cocoa+Additions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSURL (Additions)

- (NSURL *)serializeURLWithParams:(NSDictionary *)params {
	NSString* queryPrefix = self.query ? @"&" : @"?";
    
	NSMutableArray* pairs = [NSMutableArray array];
	for (NSString* key in [params keyEnumerator]) {
		NSString* escaped_value = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                               (CFStringRef)[params objectForKey:key],                                                                                          NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                               kCFStringEncodingUTF8);
        
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
	}
	NSString* query = [pairs componentsJoinedByString:@"&"];
    
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", self, queryPrefix, query]];
}

@end


@implementation NSString (MD5)

- (NSString *) MD5String {
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    
	CC_MD5( cStr, strlen(cStr), result );
    
    NSMutableString *resultString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH];
    for (NSInteger index = 0; index < CC_MD5_DIGEST_LENGTH; ++index) {
        [resultString appendFormat:@"%02X", result[index]];
    }
    
	return [resultString lowercaseString];
}
@end
