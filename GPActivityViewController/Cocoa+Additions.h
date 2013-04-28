//
//  Cocoa+Additions.h
//  Pods
//
//  Created by Gleb on 4/28/13.
//
//

@interface NSURL (Additions)
- (NSURL *)serializeURLWithParams:(NSDictionary *)params;
@end


@interface NSString (MD5)
- (NSString *) MD5String;
@end