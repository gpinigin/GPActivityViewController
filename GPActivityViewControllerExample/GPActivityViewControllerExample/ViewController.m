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

@interface ViewController ()

@property (nonatomic, strong) UIPopoverController *myPopoverController;

@end

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
    
    GPActivityViewController *controller = [[GPActivityViewController alloc] initWithactivities:@[mailActivity, messageActivity, safariActivity, mapsActivity, facebookActivity, twitterActivity, vkActivity, okActivity, photoActivity, copyActivity]];

    UIImage *image = [UIImage imageNamed:@"Activities"];
    controller.userInfo = @{@"text":@"Message to pass to activities",
                            @"url":[NSURL URLWithString:@"https://github.com/gpinigin"],
                            @"image":image,
                            @"coordinate":@{@"latitude":@(55.01769),
                                            @"longitude":@(82.945104)},
                            @"location":@"Novosibirsk"};
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad specific
        if (self.myPopoverController.isPopoverVisible) {
            [self.myPopoverController dismissPopoverAnimated:YES];
        } else {        
            self.myPopoverController= [[UIPopoverController alloc] initWithContentViewController:controller];
            controller.presentingPopoverController = self.myPopoverController;
            [self.myPopoverController presentPopoverFromBarButtonItem:self.myNavigationBarButton
                                  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    } else {
        // iPhone specific
        [controller presentFromWindow];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
