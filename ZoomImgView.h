//
//  ZoomImgView.h
//  ZoomImgView
//
//  Created by DoubleK on 16/8/31.
//  Copyright © 2016年 DoubleK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZoomImgView : UIImageView<UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIImageView *_fullImageView;
}

@end
