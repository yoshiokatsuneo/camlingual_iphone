//
//  ImagePickerCropController.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ImagePickerCropController.h"

@implementation ImagePickerCropController

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
    NSLog(@"view=%@, subviews=%@, superview=%@, superview.subviews=%@", self.view, self.view.subviews, self.view.superview, self.view.superview.subviews);
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)doTest:(id)sender {
    NSLog(@"test");
}
- (IBAction)doCapture:(id)sender
{
    NSLog(@"doCapture");
}
@end
