//
// Copyright (c) 2013 Gleb Pinigin (https://github.com/gpinigin)
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

#import "GPActivityView.h"
#import "GPActivityViewController.h"

@interface GPActivityView () {
    NSMutableArray *_activityViews;
}

@end

@implementation GPActivityView

- (id)initWithFrame:(CGRect)frame activities:(NSArray *)activities {
    self = [super initWithFrame:frame];
    if (self) {
        _activityViews = [NSMutableArray arrayWithCapacity:activities.count];
        self.clipsToBounds = YES;
        NSUInteger cancelButtonHeight = 0;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
            _backgroundImageView.image = [[UIImage imageNamed:@"GPActivityViewController.bundle/Background"] stretchableImageWithLeftCapWidth:20 topCapHeight:60];
            _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self addSubview:_backgroundImageView];

            
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _cancelButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
            [_cancelButton setBackgroundImage:[[UIImage imageNamed:@"GPActivityViewController.bundle/Button"] stretchableImageWithLeftCapWidth:22 topCapHeight:47] forState:UIControlStateNormal];
            
            NSUInteger width = 270;
            NSUInteger height = 45;
            _cancelButton.frame = CGRectMake((CGRectGetWidth(self.frame) - width) / 2,
                                             CGRectGetHeight(self.frame) - height - 15,
                                             width, height);
            
            [_cancelButton setTitle:NSLocalizedStringFromTable(@"BUTTON_CANCEL", @"GPActivityViewController", @"Cancel") forState:UIControlStateNormal];
            [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_cancelButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4] forState:UIControlStateNormal];
            [_cancelButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
            [_cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:19]];
            [_cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:_cancelButton];
            
            cancelButtonHeight = height + 15;
        }
    
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 34, frame.size.width,
                                                                     self.frame.size.height - 34 - cancelButtonHeight)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        NSInteger index = 0;
        for (GPActivity *activity in activities) {
            UIView *view = [self viewForActivity:activity index:index++];
            [_scrollView addSubview:view];
            [_activityViews addObject:view];
        }        
        
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 84, frame.size.width, 10)];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        [_pageControl addTarget:self action:@selector(pageControlValueChanged:)
               forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
        
        
        
    }
    return self;
}

- (UIView *)viewForActivity:(GPActivity *)activity index:(NSInteger)index {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(10, 0, 59, 59);
    button.tag = index;
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:activity.image forState:UIControlStateNormal];
    button.accessibilityLabel = activity.title;
    [view addSubview:button];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, 100, 30)];
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    label.shadowOffset = CGSizeMake(0, 1);
    label.text = activity.title;
    label.font = [UIFont boldSystemFontOfSize:12];
    label.numberOfLines = 0;
    [label setNumberOfLines:0];
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = roundf((view.frame.size.width - frame.size.width) / 2.0f);
    label.frame = frame;
    [view addSubview:label];
    
    return view;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSUInteger columnsInRow = CGRectGetWidth(self.scrollView.frame) / 100;
    NSUInteger rowsInPage = CGRectGetHeight(self.scrollView.frame) / 100;
    
    if (columnsInRow == 0 || rowsInPage == 0)
        return;
    
    NSUInteger offset = (CGRectGetWidth(self.scrollView.frame) - columnsInRow * 100 + 20) / 2;
    
    NSUInteger page = 0;
    NSUInteger column = 0;
    NSUInteger row = 0;
    
    for (NSUInteger index = 0; index < _activityViews.count; ++index) {
        column = index % columnsInRow;
        row = (index / columnsInRow) % rowsInPage;
        page = index / (columnsInRow * rowsInPage);
        
        UIView *view = [_activityViews objectAtIndex:index];
        view.frame = CGRectMake(offset + 100 * column +  page * _scrollView.frame.size.width,
                                100 * row, 80, 80);
        
    }
    
    _scrollView.contentSize = CGSizeMake((page +1) * _scrollView.frame.size.width, _scrollView.frame.size.height);
    _pageControl.numberOfPages = page + 1;
    
    if (_pageControl.numberOfPages > 1) {
        _scrollView.scrollEnabled = YES;
    }
}

#pragma mark - 

- (CGSize)sizeThatFits:(CGSize)size {
    NSUInteger topOffset = 25, bottomOffset = 20;
    NSUInteger minimumSize = CGRectGetHeight(_cancelButton.frame) + topOffset + bottomOffset +
                              CGRectGetHeight(_pageControl.frame);
    
    NSUInteger columnsInRow = size.width / 100;
    NSUInteger rowsInPage = (size.height - minimumSize) / 100;
    NSUInteger rows = _activityViews.count / columnsInRow;
    
    if (_activityViews.count % columnsInRow != 0) {
        rows += 1;
    }
    
    rows = (rows > rowsInPage)? rowsInPage: rows;
        
    return CGSizeMake(size.width,  100 * rows + minimumSize);
}

#pragma mark - ActivityViewActionDelegate

- (void)cancelButtonPressed {
    if ([_delegate respondsToSelector:@selector(cancelButtonTapped)]) {
        [_delegate cancelButtonTapped];
    }
}

- (void)buttonPressed:(UIButton *)button {
    if ([_delegate respondsToSelector:@selector(activityTappedAtIndex:)]) {
        [_delegate activityTappedAtIndex:button.tag];
    }    
}

#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}

#pragma mark -

- (void)pageControlValueChanged:(UIPageControl *)pageControl {
    CGFloat pageWidth = _scrollView.contentSize.width /_pageControl.numberOfPages;
    CGFloat x = _pageControl.currentPage * pageWidth;
    [_scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, _scrollView.frame.size.height) animated:YES];
}

@end
