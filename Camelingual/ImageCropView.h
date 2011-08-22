//
//  ImageCropView.h
//  test31
//
//  Created by Tsuneo Yoshioka on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCropView : UIView
{
    CGRect cropRect;
    CGRect imageRect;
}
- (void)reset;
- (UIImage*)imageByCropping;
- (CGRect)rectAdd:(CGRect)rect width:(float)width;

@property(retain) UIImage *image;
@end
