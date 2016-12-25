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

#import "GPVKActivity.h"
#import "VkontakteMgr.h"
#import "REComposeViewController.h"

NSString *const GPActivityVKontakte = @"GPActivityVKontakte";

@implementation GPVKActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_VKONTAKTE", @"GPActivityViewController", @"VKontakte");
        NSString *imageName = @"GPActivityViewController.bundle/shareVK";
        self.image = [UIImage imageNamed:imageName];
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
    controller.title = NSLocalizedStringFromTable(@"ACTIVITY_VKONTAKTE", @"GPActivityViewController", @"VKontakte");
    controller.navigationBar.tintColor = [UIColor colorWithRed:56/255.0f green:99/255.0f blue:150/255.0f alpha:1.0];

    NSString *actionTitle = ([VkontakteMgr sharedInstance].accessToken == nil)? @"BUTTON_LOGIN": @"BUTTON_POST";
    controller.navigationItem.rightBarButtonItem.title = NSLocalizedStringFromTable(actionTitle, @"GPActivityViewController", nil);
    controller.navigationItem.leftBarButtonItem.title = NSLocalizedStringFromTable(@"BUTTON_CANCEL", @"GPActivityViewController", nil);

    if (textToShare) {
        controller.text = textToShare;
    }
    
    if (image) {
        controller.hasAttachment = YES;
        controller.attachmentImage = image;
    }
    
    typeof(self) __weak weakSelf = self;
    controller.completionHandler = ^(REComposeViewController *composeViewController, REComposeResult result) {
        
        if (result == REComposeResultPosted) {
            if ([VkontakteMgr sharedInstance].accessToken) {
                [composeViewController dismissViewControllerAnimated:YES completion:nil];
                
                if (image) {
                    [[VkontakteMgr sharedInstance] shareText:composeViewController.text image:image];
                } else {
                    [[VkontakteMgr sharedInstance] shareText:composeViewController.text];
                }
                
                [weakSelf activityDidFinish:YES];
            } else {
                [[VkontakteMgr sharedInstance] retrieveAccessToken:@[@"wall,photos"] completion:^(BOOL completed) {
                    if (completed) {
                        NSString *title = NSLocalizedStringFromTable(@"BUTTON_POST", @"GPActivityViewController", @"Post");
                        composeViewController.navigationItem.rightBarButtonItem.title = title;
                    }
                }];
            }
        }
        
        if (result == REComposeResultCancelled) {
            [composeViewController dismissViewControllerAnimated:YES completion:nil];
            [weakSelf activityDidFinish:NO];
        }
    };
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [controller presentFromViewController:presentingController];
}

- (NSString *)activityType {
    return GPActivityVKontakte;
}

@end
