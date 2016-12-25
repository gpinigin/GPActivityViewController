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


#import "GPMapsActivity.h"

NSString *const kGPActivityMaps = @"GPMapsActivity";

@implementation GPMapsActivity
- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_MAPS", @"GPActivityViewController", @"Open in Maps");
        NSString *imageName = @"GPActivityViewController.bundle/shareMaps";
        self.image = [UIImage imageNamed:imageName];
    }
    
    return self;
}

#pragma mark -

- (void)performActivity {
    NSDictionary *coordinate = [self.userInfo objectForKey:@"coordinate"];
    NSNumber *longitude = [coordinate objectForKey:@"longitude"];
    NSNumber *latitude = [coordinate objectForKey:@"latitude"];
    
    NSString *location = [self.userInfo objectForKey:@"location"];
    
    NSURL *url = nil;
    if (coordinate) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com?q=%@,%@", latitude, longitude]];
    } else if (location) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com?q=%@", location]];
    } else {
        NSLog(@"Neither location nor coordinate are specified");
        return;
    }

    [[UIApplication sharedApplication] openURL:url];
}

- (NSString *)activityType {
    return kGPActivityMaps;
}

@end
