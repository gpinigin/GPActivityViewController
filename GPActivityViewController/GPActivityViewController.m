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

#import "GPActivityViewController.h"
#import "GPActivityView.h"
#import "GPActivity.h"

@interface GPActivity (ActivityContollerExtension)
- (void)prepareForActivityInfo:(NSDictionary *)activityInfo;
@end

@interface GPActivityViewController () <ActivityViewActionDelegate, UIPopoverControllerDelegate> {
    ActivityViewCompletionHandler _completionHandler;
}

@property (nonatomic, strong, readonly) UIView *backgroundView;
@property (nonatomic, strong) GPActivityView *activityView;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation GPActivityViewController

- (id)initWithActivities:(NSArray *)activities {
    self = [self initWithActivities:activities completion:nil];
    return self;
}

- (id)initWithActivities:(NSArray *)activities completion:(ActivityViewCompletionHandler)completionHandler {
    self = [super init];
    if (self) {
        _completionHandler = completionHandler;

        NSUInteger positionY = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
            _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            _backgroundView.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 0;
            [self.view addSubview:_backgroundView];

            positionY = self.view.frame.size.height;
        } else {
            self.view.frame = CGRectMake(0, 0, 320, 480);
        }

        _activities = activities;

        CGRect frame = self.view.frame;
        _activityView = [[GPActivityView alloc] initWithFrame:CGRectMake(0, positionY, CGRectGetWidth(frame),
                                                                         CGRectGetHeight(frame))
                                                   activities:activities];
        _activityView.delegate = self;


        CGSize size = [_activityView sizeThatFits:_activityView.frame.size];
        frame = _activityView.frame;
        frame.size = size;
        _activityView.frame = frame;

        [self.view addSubview:_activityView];
        self.contentSizeForViewInPopover = CGSizeMake(320, size.height);
    }
    return self;
}

#pragma mark -

- (void)loadView {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    } else {
        [super loadView];
    }
}

#pragma mark -

- (void)dismissViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {

    NSTimeInterval duration = animated? 0.4: 0.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (!self.window) {
            [super dismissViewControllerAnimated:animated completion:completion];
        }

        typeof(self) __weak weakSelf = self;
        [UIView animateWithDuration:duration animations:^{
            _backgroundView.alpha = 0;
            CGRect frame = _activityView.frame;
            frame.origin.y = [UIScreen mainScreen].bounds.size.height;
            _activityView.frame = frame;
        } completion:^(BOOL finished) {
            if (weakSelf.window) {
                weakSelf.window.hidden = YES;
                weakSelf.window = nil;
            }

            if (completion)
                completion();
        }];
    } else {
        [self.presentingPopoverController dismissPopoverAnimated:animated];
        [self performBlock:^{
            if (completion)
                completion();
        } afterDelay:duration];
    }
}

- (void)presentModalViewControllerAnimated:(UIViewController *)controller {
    [controller presentViewController:self animated:YES completion:nil];
    
    _backgroundView.frame = controller.view.bounds;
    
    typeof(self) __weak weakSelf = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.backgroundView.alpha = 0.4;
            
            CGRect frame = weakSelf.activityView.frame;
            NSUInteger height = UIInterfaceOrientationIsLandscape(weakSelf.interfaceOrientation)? CGRectGetWidth(weakSelf.view.frame):CGRectGetHeight(weakSelf.view.frame);
            frame.origin.y = height - CGRectGetHeight(frame);
            weakSelf.activityView.frame = frame;
        }];
    }
}

- (void)presentFromWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = self;
    [self.window makeKeyAndVisible];
    
    _backgroundView.frame = self.view.bounds;
    
    typeof(self) __weak weakSelf = self;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.backgroundView.alpha = 0.4;
            
            CGRect frame = weakSelf.activityView.frame;
            NSUInteger height = UIInterfaceOrientationIsLandscape(weakSelf.interfaceOrientation)?CGRectGetWidth(weakSelf.view.frame):CGRectGetHeight(weakSelf.view.frame);
            frame.origin.y = height - CGRectGetHeight(frame);
            weakSelf.activityView.frame = frame;
        }];
    }
}

- (void)presentFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _presentingPopoverController = [[UIPopoverController alloc] initWithContentViewController:self];
        _presentingPopoverController.delegate = self;
        [_presentingPopoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
    } else {
        [self presentFromWindow];
    }
}

- (void)presentFromBarButton:(UIBarButtonItem *)buttonItem animated:(BOOL)animated {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _presentingPopoverController = [[UIPopoverController alloc] initWithContentViewController:self];
        _presentingPopoverController.delegate = self;
        [_presentingPopoverController presentPopoverFromBarButtonItem:buttonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:animated];
    } else {
        [self presentFromWindow];
    }
}

- (BOOL)isVisible {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [_presentingPopoverController isPopoverVisible];
    }

    return (_window != nil);

}

- (void)dismissAnimated:(BOOL)animated {
    [self dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - Helpers

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay {
    block = [block copy];
    [self performSelector:@selector(runBlockAfterDelay:) withObject:block afterDelay:delay];
}

- (void)runBlockAfterDelay:(void (^)(void))block {
	if (block != nil)
		block();
}

#pragma mark - popover

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (_completionHandler)
        _completionHandler(nil, NO);
}

#pragma mark - ActivityViewActionDelegate

- (void)cancelButtonTapped {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (_completionHandler)
        _completionHandler(nil, NO);
}

- (void)activityTappedAtIndex:(NSUInteger)index {
    GPActivity *activity = [_activities objectAtIndex:index];
    activity.completionBlock = _completionHandler;
    
    [activity prepareForActivityInfo:self.userInfo];
    [self dismissViewControllerAnimated:YES completion:^() {        
        [activity performActivity];
    }];
}

#pragma mark - handling rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:duration animations:^() {
        NSUInteger width = 0;
        NSUInteger height = 0;
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            width = size.height;
            height = size.width;
        } else {
            width = size.width;
            height = size.height;
        }

        [weakSelf updateGridFrame:CGSizeMake(width, height)];
    }];
}

#pragma mark -

- (void)updateGridFrame:(CGSize)desiredSize {
    CGSize size = [_activityView sizeThatFits:desiredSize];
    CGRect frame = _activityView.frame;
    frame.size = size;
    frame.origin.y = desiredSize.height - size.height;
    _activityView.frame = frame;
}

#pragma mark - autorotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return YES;

    return (orientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
