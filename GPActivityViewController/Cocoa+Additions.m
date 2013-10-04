//
// Copyright (c) 2013 Gleb Pinigin (https://github.com/gpinigin)
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

#import "Cocoa+Additions.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSURL (Additions)

- (NSURL *)serializeURLWithParams:(NSDictionary *)params {
    if (params == nil)
        return self;
    
	NSString *queryPrefix = self.query ? @"&" : @"?";
    
	NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [params keyEnumerator]) {
        id valueForKey = [params objectForKey:key];
        NSString *value = [valueForKey isKindOfClass:[NSString class]]? valueForKey: [valueForKey stringValue];

		NSString *escapedValue = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
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
