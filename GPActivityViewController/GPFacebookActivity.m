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

#import "GPFacebookActivity.h"
#import "DEFacebookComposeViewController.h"
#import <Social/Social.h>

NSString *const GPActivityFacebook = @"GPActivityFacebook";

@implementation GPFacebookActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_FACEBOOK", @"GPActivityViewController", @"Facebook");
        self.image = [UIImage imageNamed:@"GPActivityViewController.bundle/shareFacebook"];
    }

    return self;
}

- (NSString *)activityType {
    return GPActivityFacebook;
}

- (void)performActivity {    
    NSString *text = [self.userInfo objectForKey:@"text"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    UIImage *image = [self.userInfo objectForKey:@"image"];
    
    DEFacebookComposeViewController *composeController = [[DEFacebookComposeViewController alloc] init];
    if (text) {
        [composeController setInitialText:text];
    }
    
    if (url) {
        [composeController addURL:url];
    }
    
    if (image) {
        [composeController addImage:image];
    }
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    presentingController.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    __typeof(&*self) __weak weakSelf = self;
    composeController.completionHandler = ^(DEFacebookComposeViewControllerResult result) {
        [weakSelf activityFinished:result == DEFacebookComposeViewControllerResultDone];
    };
    
    [presentingController presentViewController:composeController animated:YES completion:nil];
}

@end
