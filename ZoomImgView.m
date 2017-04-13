//
//  ZoomImgView.m
//  ZoomImgView
//
//  Created by DoubleK on 16/8/31.
//  Copyright © 2016年 DoubleK. All rights reserved.
//

#import "ZoomImgView.h"

@implementation ZoomImgView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initTap];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _initTap];
}

- (void)_initTap
{
    //单击放大
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomInAction)];
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

- (void)zoomInAction
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        //设置缩放系数
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.0;
        [self.window addSubview:_scrollView];
        
        //双击放大/缩小
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [_scrollView addGestureRecognizer:doubleTap];
        
        //单击恢复原图
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOutAction)];
        [_scrollView addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    
    if (!_fullImageView) {
        _fullImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _fullImageView.contentMode = UIViewContentModeScaleAspectFit;
        _fullImageView.image = self.image;
        [_scrollView addSubview:_fullImageView];
    }
    
    //放大效果
    CGRect rect = [self convertRect:self.bounds toView:_scrollView];
    _fullImageView.frame = rect;
    
    [UIView animateWithDuration:0.5 animations:^{
        _scrollView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.377];
        
        CGFloat hei = _fullImageView.image.size.height;
        CGFloat wid = _fullImageView.image.size.width;
        
        CGFloat x_Scale = wid/_scrollView.frame.size.width;
        CGFloat y_Scale = hei/_scrollView.frame.size.height;
        CGRect newFrame = CGRectZero;
        if (x_Scale >= y_Scale) {
            newFrame = CGRectMake(0,(_scrollView.frame.size.height - hei/x_Scale)/2.0, wid/x_Scale, hei/x_Scale);
        }
        else
        {
            newFrame = CGRectMake((_scrollView.frame.size.width-wid/y_Scale)/2.0, 0, wid/y_Scale, hei/y_Scale);
        }
        _fullImageView.frame = newFrame;
    }];
}

- (void)zoomOutAction
{
    //显示状态栏
    [UIView animateWithDuration:0.5
                     animations:^{
                         _fullImageView.frame = [self convertRect:self.bounds toView:_scrollView];
                         _scrollView.backgroundColor = [UIColor clearColor];
                     } completion:^(BOOL finished) {
                         [_scrollView removeFromSuperview];
                         _scrollView = nil;
                         _fullImageView = nil;
                     }];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)gesture
{
    if (_scrollView.zoomScale > 1.0) {
        [_scrollView setZoomScale:1.0 animated:YES];
    }
    else
    {
        [_scrollView setZoomScale:2.0 animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _fullImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat xPoint = scrollView.center.x;
    CGFloat yPoint = scrollView.center.y;
    xPoint = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2:xPoint;
    yPoint = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2:yPoint;
    _fullImageView.center = CGPointMake(xPoint, yPoint);
}

@end
