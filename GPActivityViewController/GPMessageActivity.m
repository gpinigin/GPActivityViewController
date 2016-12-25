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

#import "GPMessageActivity.h"
#import <MessageUI/MessageUI.h>

NSString *const GPActivityMessage = @"GPActivityMessage";

@interface GPMessageActivity () <MFMessageComposeViewControllerDelegate>
@end

@implementation GPMessageActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_MESSAGE", @"GPActivityViewController", @"Message");
        NSString *imageName = @"GPActivityViewController.bundle/shareMessage";
        self.image = [UIImage imageNamed:imageName];
    }

    return self;
}

#pragma mark - 

- (NSString *)activityType {
    return GPActivityMessage;
}

- (void)performActivity {
    NSString *text = [self.userInfo objectForKey:@"text"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    
    MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
    if (!messageComposeViewController) {
        [self activityDidFinish:NO];
        return;
    }

    messageComposeViewController.messageComposeDelegate = self;
    
    NSString *message = @"";
    if (text) {
        message = [message stringByAppendingString:text];
    }
    
    if (url) {
        message = [message stringByAppendingFormat:@" %@", url.absoluteString];
    }
  
    messageComposeViewController.body = message;
        
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [presentingController presentViewController:messageComposeViewController animated:YES completion:nil];
}

#pragma mark - delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self activityDidFinish:(result == MessageComposeResultSent)];
}

@end
