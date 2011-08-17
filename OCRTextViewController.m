//
//  OCRTextViewController.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OCRTextViewController.h"

@implementation OCRTextViewController

@synthesize textView;
@synthesize delegate = _delegate;

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
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)show:(UIViewController *)parent text:(NSString *)text delegate:(id<OCRTextViewControllerDelegate>)delegate
{
    [parent presentModalViewController:self animated:YES];
    self.textView.text = text;
    [self.textView becomeFirstResponder];
    self.delegate = delegate;
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)ok:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    [self.delegate didFinishOCRTextViewController:self.textView.text];
}
- (void)dealloc {
    [textView release];
    [super dealloc];
}
@end
