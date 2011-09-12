//
//  ImageCropViewController.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImageCropViewController.h"
#import "ImageCropView.h"

@implementation ImageCropViewController
@synthesize imageCropView = _imageCropView;
@synthesize delegate = _delegate;
@synthesize image = _image;
@synthesize imageView = _imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.imageCropView.image = self.image;
    CGRect frame = [self.imageCropView rectAdd:self.imageCropView.bounds width:-10];
    self.imageView = [[[UIImageView alloc] initWithFrame:frame] autorelease];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.imageView.image = self.image;
    [self.view insertSubview:self.imageView belowSubview:self.imageCropView];
    
    //[self.imageCropView reset];
    //[self.imageCropView setNeedsDisplay];
}
- (void)viewDidUnload
{
    [self setImageCropView:nil];
    self.imageView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.imageCropView setNeedsDisplay];
}
- (IBAction)ok:(id)sender {
    UIImage *cropImage = [self.imageCropView imageByCropping];
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didFinishImageCropViewController:self cropImage:cropImage cropRect:self.imageCropView.cropRect];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didCancelImageCropViewController:self];
}

#if 0
- (void)showModal:(UIViewController*)parent image:(UIImage*)image delegate:(id<ImageCropViewControllerDelegate>)delegate
{
    self.delegate = delegate;
    self.imageCropView.image = self.imageView.image = self.image = image;
    [self.imageCropView reset];
    [parent presentModalViewController:self animated:YES];
    
}
#endif
- (void)show:(UIViewController*)parent image:(UIImage*)image cropRect:(CGRect)cropRect delegate:(id<ImageCropViewControllerDelegate>)delegate
{
    self.delegate = delegate;
    
    self.imageCropView.image = self.imageView.image = self.image = image;
    self.imageCropView.cropRect = cropRect;
    [self.imageCropView setNeedsDisplay];
    
    NSLog(@"parent=%@", parent);
    NSLog(@"parent.view=%@", parent.view);
    NSLog(@"parent.view.window=%@", parent.view.window);
    parent.view.window.rootViewController = self;
    // parent.view = self.view;
    
}
- (void)dealloc {
    [_imageCropView release];
    [super dealloc];
}
@end
