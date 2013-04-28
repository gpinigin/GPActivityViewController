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

#import "GPOKActivity.h"
#import <REComposeViewController.h>
#import "OdnoklassnikiMgr.h"

NSString *const GPActivityOdnoklassniki = @"GPActivityOdnoklassniki";

@implementation GPOKActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_ODNOKLASSNIKI", @"GPActivityViewController", @"Odnoklassniki");
        self.image = [UIImage imageNamed:@"GPActivityViewController.bundle/shareOK"];
    }

    return self;
}

#pragma mark -

- (void)performActivity {
    NSString *text = [self.userInfo objectForKey:@"text"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    UIImage *image = [self.userInfo objectForKey:@"image"];
    
    NSString *textToShare;
    if (text && !url)
        textToShare = text;
    
    if (!text && url)
        textToShare = url.absoluteString;
    
    if (text && url)
        textToShare = [NSString stringWithFormat:@"%@ %@", text, url.absoluteString];
    
    REComposeViewController *controller = [[REComposeViewController alloc] init];
    if (![OdnoklassnikiMgr sharedInstance].accessToken) {
        NSString *title = NSLocalizedStringFromTable(@"BUTTON_LOGIN", @"GPActivityViewController", @"Login");
        controller.navigationItem.rightBarButtonItem.title = title;
    }
    
    controller.title = NSLocalizedStringFromTable(@"ACTIVITY_ODNOKLASSNIKI", @"GPActivityViewController", @"Odnoklassniki");
    controller.navigationBar.tintColor = [UIColor colorWithRed:245/255.0f green:130/255.0f blue:35/255.0f alpha:1.0];
    
    if (textToShare)
        controller.text = textToShare;
    if (image) {
        controller.hasAttachment = YES;
        controller.attachmentImage = image;
    }
    
    __typeof(&*self) __weak weakSelf = self;
    controller.completionHandler = ^(REComposeViewController *composeViewController, REComposeResult result) {
        if (result == REComposeResultPosted) {
            if ([OdnoklassnikiMgr sharedInstance].accessToken) {
                [[OdnoklassnikiMgr sharedInstance] shareURL:url.absoluteString description:composeViewController.text];
                [composeViewController dismissViewControllerAnimated:YES completion:nil];
                [weakSelf activityFinished:YES];
            } else {
                [[OdnoklassnikiMgr sharedInstance] retrieveAccessToken:@[@"VALUABLE ACCESS"] completion:^() {
                    NSString *title = NSLocalizedStringFromTable(@"BUTTON_POST", @"GPActivityViewController", @"Post");
                    composeViewController.navigationItem.rightBarButtonItem.title = title;
                }];
            }
        }
        
        if (result == REComposeResultCancelled) {
            [composeViewController dismissViewControllerAnimated:YES completion:nil];
            [weakSelf activityFinished:NO];
        }
    };
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [controller presentFromViewController:presentingController];
}

- (NSString *)activityType {
    return GPActivityOdnoklassniki;
}


@end
