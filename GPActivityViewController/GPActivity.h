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

#import <Foundation/Foundation.h>
#import "GPActivityViewController.h"

typedef enum {
    GPActivityCategoryAction,
    GPActivityCategoryShare,
} GPActivityCategory;

@class GPActivity;

typedef void (^GPActivityActionHandler)(GPActivity *activity, NSDictionary *userInfo);

@interface GPActivity : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSDictionary *userInfo;

@property (nonatomic, copy) ActivityViewCompletionHandler completionBlock;

+ (instancetype)customActivity:(NSString *)activityType actionHandler:(GPActivityActionHandler)block;

// State
- (void)activityDidFinish:(BOOL)completed;

// subclassing
+ (GPActivityCategory)activityCategory; // return share action for activity - GPActivityCategoryShare is default.
- (NSString *)activityType; // return custom activity type that is reported to completion handler
- (void)performActivity;    // perform activity related work

@end
