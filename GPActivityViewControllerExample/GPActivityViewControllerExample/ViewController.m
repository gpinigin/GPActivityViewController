//
//  ViewController.m
//  GPActivityViewControllerExample
//
//  Created by Gleb on 5/6/13.
//  Copyright (c) 2013 Gleb Pinigin. All rights reserved.
//

#import "ViewController.h"
#import "GPActivities.h"
#import "GPActivityViewController.h"

@implementation ViewController

- (IBAction)shareAction:(id)sender {
    // DO NOT forget to  setup application IDs in info.plist. For more info see README.md
    GPFacebookActivity *facebookActivity = [GPFacebookActivity new];
    GPTwitterActivity *twitterActivity = [GPTwitterActivity new];
    GPCopyActivity *copyActivity = [GPCopyActivity new];
    GPMailActivity *mailActivity = [GPMailActivity new];
    GPMessageActivity *messageActivity = [GPMessageActivity new];
    GPOKActivity *okActivity = [GPOKActivity new];
    GPVKActivity *vkActivity = [GPVKActivity new];
    GPSafariActivity *safariActivity = [GPSafariActivity new];
    GPMapsActivity *mapsActivity = [GPMapsActivity new];
    GPPhotoActivity *photoActivity = [GPPhotoActivity new];

    NSArray *activities = @[mailActivity, messageActivity, safariActivity, mapsActivity, facebookActivity, twitterActivity, vkActivity, okActivity, photoActivity, copyActivity];
    GPActivityViewController *controller = [[GPActivityViewController alloc] initWithActivities:activities completion:^(NSString *activityType, BOOL completed) {
        if (completed) {
            if (activityType) {
                NSLog(@"Activity done: %@", activityType);
            }
        }
    }];

    UIImage *image = [UIImage imageNamed:@"Activities"];
    controller.userInfo = @{@"text":@"Message to pass to activities",
                            @"url":[NSURL URLWithString:@"https://github.com/gpinigin"],
                            @"image":image,
                            @"coordinate":@{@"latitude":@(55.01769),
                                            @"longitude":@(82.945104)},
                            @"location":@"Novosibirsk"};
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller presentFromBarButton:sender animated:YES];
    } else {
        UIButton *button = (UIButton *)sender;
        [controller presentFromRect:button.frame inView:button.superview animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
