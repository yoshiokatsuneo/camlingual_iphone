//
//  ImageCropViewController.h
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
- (void)show:(UIViewController*)parent image:(UIImage*)image delegate:(id<ImageCropViewControllerDelegate>)delegate;
@end

@protocol ImageCropViewControllerDelegate <NSObject>
- (void)didFinishImageCropViewController:(id)sender cropImage:(UIImage*)cropImage;
- (void)didCancelImageCropViewController:(id)sender;
@end

