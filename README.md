GPActivityViewController
========================

Alternative to UIActivityViewController compatible with iOS5.0

![Screenshot](https://github.com/gpinigin/GPActivityViewController/raw/master/Activities.png)


###Supported activities
* Facebook
* Twitter
* Vkontakte
* Odnoklassniki
* Mail
* Messages
* Copy
* Camera Roll
* Maps
* Safari


### Requirements
* XCode 4.4+
* Deployment Target iOS5.0+
* ARC
 

### Features
* Landscape support
* Pagination
* Custom activities
* Activity customization
* ActivityViewController completion handler
 
## Installation
The recommended way is to use [CocoaPods](http://cocoapods.org/) package manager.

To install using CocoaPods open your Podfile and add:
``` bash
 pod 'GPActivityViewController', '~> 1.1.0'
```



##Social networks integration
###Facebook
* Set up **FacebookAppID** property in your info.plist file, i.e.  FacebookAppID = 12345678
* Set up URL scheme for facebook redirect: fbFacebookAppID , where FacebookAppID - Facebook application ID

###Odnoklassniki
* Set up properties **OdnoklassnikiAppID**, **OdnoklassnikiSecretKey**, **OdnoklassnikiAppKey** in your info.plist file.
* Set up URL scheme for redirect: okOdnoklassnikiAppID , where OdnoklassnikiAppID - Odnoklassniki application ID

###Vkontakte
* Set up **VKontakteAppID** property in your info.plist file


## Usage
### Activity controller
``` objective-c
    // DO NOT forget to  setup application IDs in info.plist. For more info see README.md
    GPFacebookActivity *facebookActivity = [GPFacebookActivity new];
    GPTwitterActivity *twitterActivity = [GPTwitterActivity new];
    GPCopyActivity *copyActivity = [GPCopyActivity new];
    GPMailActivity *mailActivity = [GPMailActivity new];
    GPMessageActivity *messageActivity = [GPMessageActivity new];
    GPOKActivity *okActivity = [GPOKActivity new];
    GPVKActivity *vkActivity = [GPVKActivity new];
    
    NSArray *activities = @[mailActivity, messageActivity, facebookActivity, twitterActivity,
                            vkActivity, okActivity, copyActivity];
    GPActivityViewController *controller = [[GPActivityViewController alloc] initWithactivities:activities];

    controller.userInfo = @{@"text":@"Message to pass to activities",
                            @"url":[NSURL URLWithString:@"https://github.com/gpinigin"]};
    
    
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
```

### Subclassing notes
``` objective-c
// Call it when activity is finished
- (void)activityFinished:(BOOL)completed;

// Should returns string that unique identifies your activity
- (NSString *)activityType;

// Override to implement your activity behavior
- (void)performActivity;
```

Note for iOS5.0: if autoorientation behavior of your controller isn't match to one of GPActivityViewController you MUST subclass GPActivityViewController to override autorotation behavior or present controller modally

### Custom activities
You also can make your custom activity using block approach:
``` objective-c
   GPActivity *myActivity = [customActivity:@"MACustomActivity" actionHandler:^(GPActivity *activity, NSDictionary *userInfo) {
        // Your code here
        //    ...
        
        // Activity is finished successfully
        [activity activityFinished:YES];
   }];
   
   myActivity.image = [UIImage imageNamed:@"myCustom"];
   myActivity.title = @"MyCustom";
```

You can also specify predefined acitivityInfo:
``` objective-c
   NSURL *url = [NSURL URLWithString:@"google.com"];
   activity.userInfo = @{@"text":@"My custom activity",
                         @"url":url};
```

##Credits
Partially based on [REActivityViewController](https://github.com/romaonthego/REActivityViewController)
