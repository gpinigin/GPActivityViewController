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

#import "GPActivity.h"

@interface GPActivity () {
    GPActivityActionHandler _actionHandler;
    NSString *_activityType;
    NSDictionary *_activityInfo;
}

@end

@implementation GPActivity

+ (instancetype)customActivity:(NSString *)activityType actionHandler:(GPActivityActionHandler)block {
    GPActivity *activity = [GPActivity new];
    
    activity->_actionHandler = [block copy];
    activity->_activityType = activityType;
    activity.title = NSLocalizedStringFromTable(@"ACTIVITY_CUSTOM", @"GPActivityViewController", @"Custom");

    NSString *imageName = @"GPActivityViewController.bundle/shareCustom";
    activity->_image = [UIImage imageNamed:imageName];

    return activity;
}

#pragma mark -

- (void)activityDidFinish:(BOOL)completed {
    if (_completionBlock) {
        _completionBlock([self activityType], completed);
    }
}

- (void)prepareForActivityInfo:(NSDictionary *)activityInfo {
    if (_userInfo == nil) {
        _userInfo = activityInfo;
    }
}

#pragma mark - subclassing

+ (GPActivityCategory)activityCategory {
    return GPActivityCategoryShare;
}

- (NSString *)activityType {
    return _activityType;
}

- (void)performActivity {
    if (_actionHandler) {
        _actionHandler(self, _userInfo);
    }
}

@end
