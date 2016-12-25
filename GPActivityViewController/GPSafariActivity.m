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


#import "GPSafariActivity.h"

NSString *const kGPSafariActivity = @"GPSafariActivity";

@implementation GPSafariActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_SAFARI", @"GPActivityViewController", @"Open in Safari");
        NSString *imageName = @"GPActivityViewController.bundle/shareSafari";
        self.image = [UIImage imageNamed:imageName];
    }
    
    return self;
}

#pragma mark -

+ (GPActivityCategory)activityCategory {
    return GPActivityCategoryAction;
}

- (NSString *)activityType {
    return kGPSafariActivity;
}

- (void)performActivity {
    NSURL *url = [self.userInfo objectForKey:@"url"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
