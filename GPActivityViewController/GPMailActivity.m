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

#import "GPMailActivity.h"
#import <MessageUI/MessageUI.h>

NSString *const GPActivityMail = @"GPActivityMail";
 
@interface GPMailActivity () <MFMailComposeViewControllerDelegate>
@end

@implementation GPMailActivity

- (id)init {
    self =  [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_MAIL", @"GPActivityViewController", @"Mail");
        NSString *imageName = @"GPActivityViewController.bundle/shareMail";
        self.image = [UIImage imageNamed:imageName];
    }

    return self;
}

#pragma mark - 

- (void)performActivity {
    NSString *subject = [self.userInfo objectForKey:@"subject"];
    NSString *text = [self.userInfo objectForKey:@"text"];
    UIImage *image = [self.userInfo objectForKey:@"image"];
    NSURL *url = [self.userInfo objectForKey:@"url"];
    
    MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
    if (!mailComposeViewController) {
        [self activityDidFinish:NO];
        return;
    }
    mailComposeViewController.mailComposeDelegate = self;
    
    NSString *message = @"";
    if (text) {
        message = [message stringByAppendingString:text];
    }
    
    if (url) {
        message = [message stringByAppendingFormat:@" %@", url.absoluteString];
    }
    
    [mailComposeViewController setMessageBody:message isHTML:YES];
        
    
    if (image) {
        [mailComposeViewController addAttachmentData:UIImageJPEGRepresentation(image, 0.75f) mimeType:@"image/jpeg" fileName:@"photo.jpg"];
    }
    
    if (subject) {
        [mailComposeViewController setSubject:subject];
    }
    
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [presentingController presentViewController:mailComposeViewController animated:YES completion:nil];
}

- (NSString *)activityType {
    return GPActivityMail;
}

#pragma mark - delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self activityDidFinish:(result == MFMailComposeResultSent)];
}


@end
