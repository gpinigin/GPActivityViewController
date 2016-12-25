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

#import "GPTwitterActivity.h"
#import <Twitter/Twitter.h>

NSString *const GPActivityTwitter = @"GPActivityTwitter";

@implementation GPTwitterActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_TWITTER", @"GPActivityViewController", @"Twitter");
        NSString *imageName = @"GPActivityViewController.bundle/shareTwitter";
        self.image = [UIImage imageNamed:imageName];
    }

    return self;
}


#pragma mark - 

- (void)performActivity {
    typeof(self) __weak weakSelf = self;
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];

    typeof(controller) __weak weakComposer = controller;
    controller.completionHandler = ^(SLComposeViewControllerResult result) {
        [weakComposer dismissViewControllerAnimated:YES completion:nil];
        [weakSelf activityDidFinish:(result == SLComposeViewControllerResultDone)];
    };


    NSString *text = [self.userInfo objectForKey:@"text"];
    UIImage *image = [self.userInfo objectForKey:@"image"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    
    if (text) {
        [controller setInitialText:text];
    }
    
    if (image) {
        [controller addImage:image];
    }
    
    if (url) {
        [controller addURL:url];
    }
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [presentingController presentViewController:controller animated:YES completion:nil];
}

- (NSString *)activityType {
    return GPActivityTwitter;
}

@end
