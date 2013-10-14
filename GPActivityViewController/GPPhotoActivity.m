//
//  GPPhotoActivity.m
//  Pods
//
//  Created by Gleb on 5/25/13.
//
//

#import "GPPhotoActivity.h"

NSString *const kGPActivityPhoto = @"GPPhotoActivity";

@implementation GPPhotoActivity

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedStringFromTable(@"ACTIVITY_PHOTO", @"GPActivityViewController", @"Save to Camera Roll");
        self.image = [UIImage imageNamed:@"GPActivityViewController.bundle/sharePhotos"];
    }
    
    return self;
}

#pragma mark -

+ (GPActivityCategory)activityCategory {
    return GPActivityCategoryAction;
}

- (NSString *)activityType {
    return kGPActivityPhoto;
}

- (void)performActivity {
    UIImage *image = [self.userInfo objectForKey:@"image"];
    
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
}

@end
