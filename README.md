GPActivityViewController
========================

Alternative to UIActivityViewController compatible with iOS5.0

###Supported activities
* Facebook
* Twitter
* Vkontakte
* Odnoklassniki
* Mail
* Messages
* Copy


###Requirements
* XCode 4.4+
* Deployment Target iOS5.0+
* ARC
 

### Features
* Landscape support
* Pagination
* Custom activities
* Activity customization
* ActivityViewController completion handler


##Social networks integration
###Facebook
* Set up **FacebookAppID** property in your info.plist file, i.e.  FacebookAppID = 12345678
* Set up URL scheme for facebook redirect: fb<FacebookAppID> , where <FacebookAppID> - Facebook application ID

###Odnoklassniki
* Set up properties **OdnoklassnikiAppID**, **OdnoklassnikiSecretKey**, **OdnoklassnikiAppKey** in your info.plist file.
* Set up URL scheme for redirect: ok<OdnoklassnikiAppID> , where <OdnoklassnikiAppID> - Odnoklassniki application ID

###Vkontakte
* Set up **VKontakteAppID** property in your info.plist file


## Usage
### Activity controller
``` objective-c
   GPFacebookActivity *facebookActivity = [[GPFacebookActivity alloc] init];
   GPTwitterActivity *twitterActivity = [[GPTwitterActivity alloc] init];
   GPActivityViewController *controller = [[GPActivityViewController alloc] initWithactivities:@[facebookActivity, twitterActivity]];
   
   controller.userInfo = @{@"text":"Message to pass to activities"};
   
     
   if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
       // iPad specific
       UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:controller];
       controller.presentingPopoverController = self.popoverController;
       [popoverController presentPopoverFromBarButtonItem:myNavigationBarButton                 
                                 permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
