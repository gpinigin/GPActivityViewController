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

#import "GPTwitterActivity.h"
#import <Twitter/Twitter.h>

NSString *const GPActivityTwitter = @"GPActivityTwitter";

@implementation GPTwitterActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_TWITTER", @"GPActivityViewController", @"Twitter");
        self.image = [UIImage imageNamed:@"GPActivityViewController.bundle/shareTwitter"];
    }

    return self;
}


#pragma mark - 

- (void)performActivity {
    typeof(self) __weak weakSelf = self;
    
    id composeController;
    if ([SLComposeViewController class]) {
        composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        typeof(composeController) __weak weakComposer = composeController;
        ((SLComposeViewController *)composeController).completionHandler = ^(SLComposeViewControllerResult result) {
            [weakComposer dismissViewControllerAnimated:YES completion:nil];
            [weakSelf activityFinished:(result == SLComposeViewControllerResultDone)];
        };
    } else {
        composeController = [[TWTweetComposeViewController alloc] init];
        
        typeof(composeController) __weak weakComposer = composeController;
        ((TWTweetComposeViewController *)composeController).completionHandler = ^(TWTweetComposeViewControllerResult result) {
            [weakComposer dismissViewControllerAnimated:YES completion:nil];
            [weakSelf activityFinished:(result == TWTweetComposeViewControllerResultDone)];
        };
    }
    
    NSString *text = [self.userInfo objectForKey:@"text"];
    UIImage *image = [self.userInfo objectForKey:@"image"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    
    if (text) {
        [composeController setInitialText:text];
    }
    
    if (image) {
        [composeController addImage:image];
    }
    
    if (url) {
        [composeController addURL:url];
    }
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [presentingController presentModalViewController:composeController animated:YES];
}

- (NSString *)activityType {
    return GPActivityTwitter;
}

@end
