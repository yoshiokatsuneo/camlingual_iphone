//
//  ImageCropViewController.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 Copyright (C) Yoshioka Tsuneo (yoshiokatsuneo@gmail.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import <UIKit/UIKit.h>
#import "ImageCropView.h"

@protocol ImageCropViewControllerDelegate;

@interface ImageCropViewController : UIViewController
{
    ;
    ImageCropView *_imageCropView;
}
@property (nonatomic, retain) IBOutlet ImageCropView *imageCropView;
@property(retain) id<ImageCropViewControllerDelegate> delegate;

@property(retain) UIImage *image;
@property(retain) UIImageView *imageView;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (void)show:(UIViewController*)parent image:(UIImage*)image cropRect:(CGRect)cropRect delegate:(id<ImageCropViewControllerDelegate>)delegate;
@end

@protocol ImageCropViewControllerDelegate <NSObject>
- (void)didFinishImageCropViewController:(id)sender cropImage:(UIImage*)cropImage cropRect:(CGRect)cropRect;
- (void)didCancelImageCropViewController:(id)sender;
@end

