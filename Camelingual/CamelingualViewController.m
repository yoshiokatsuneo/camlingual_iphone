//
//  CamelingualViewController.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamelingualViewController.h"
#import "OCRWebService.h"

@implementation CamelingualViewController
@synthesize toolbar;
@synthesize webView;
@synthesize imageView;
@synthesize notificationLabel;
@synthesize activityIndicatorView;
@synthesize progressView;
@synthesize ocrTextView;
@synthesize translateTextView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    aOCRWebService = [[OCRWebService alloc] init];
    aOCRWebService.user_name = @"YOSHIOKATSUNEO";
    aOCRWebService.license_code = @"BE21E7D3-1D0A-4405-8465-A547917C333C";
    
    aGoogleTranslateAPI = [[GoogleTranslateAPI alloc] init];
}

- (void)viewDidUnload
{
    [aOCRWebService release]; aOCRWebService = nil;
    [aGoogleTranslateAPI release]; aGoogleTranslateAPI = nil;
    
    [self setWebView:nil];
    [self setImageView:nil];
    [self setToolbar:nil];
    [self setNotificationLabel:nil];
    [self setActivityIndicatorView:nil];
    [self setProgressView:nil];
    [self setOcrTextView:nil];
    [self setTranslateTextView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [webView release];
    [imageView release];
    
    [popover release];
    [actionSheetButtonIndex2sourceType release];
    
    [toolbar release];
    [notificationLabel release];
    [activityIndicatorView release];
    [progressView release];
    [ocrTextView release];
    [translateTextView release];
    [super dealloc];
}

- (void)errorAlert:(NSError*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[[error userInfo] description] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    //[activityIndicatorView stopAnimating];
    
    // notificationLabel.text = @"UIImageWriteToSavedPhotosAlbum end...";
    ;
}
- (void)showGoogleTranslatePage:(NSString*)text
{
    NSString *encodedOcrText = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)text, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);

    NSString *urlstr = [NSString stringWithFormat:@"http://translate.google.com/m/translate"];
    NSURL *url = [NSURL URLWithString:urlstr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Encoding"];
    [request setValue:@"Camelingual" forHTTPHeaderField:@"User_Agent"];
    NSString *bodystr = [NSString stringWithFormat:@"rls=en&q=%@",encodedOcrText];
    [request setHTTPBody:[bodystr dataUsingEncoding:NSUTF8StringEncoding]];    
    [webView loadRequest:request];
    
    notificationLabel.text = @"";
}



- (void)OCRWebServiceProgress:(OCRWebService *)aOCRWebServer message:(NSString *)message progress:(float)progress
{
    notificationLabel.text = message;
    if(progress>=0){
        progressView.progress = progress;
        progressView.hidden = NO;
    }else{
        progressView.hidden = YES;
    }
}
-(void)OCRWebService:(OCRWebService *)aOCRWebService didFailWithError:(NSError *)error
{
    [self errorAlert:error];
    [activityIndicatorView stopAnimating];
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
}
-(void)OCRWebServiceDidFinish:(OCRWebService *)aOCRWebService ocrText:(NSString*)ocrText;
{
    [aGoogleTranslateAPI translate:ocrText delegate:self];
    // [self showGoogleTranslatePage:ocrText];
    
    [activityIndicatorView stopAnimating];
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
}


- (void)translate:(GoogleTranslateAPI *)aGoogleTranslateAPI didFailWithError:(NSError *)error
{
    [self errorAlert:error];
    [activityIndicatorView stopAnimating];
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
}
- (void)translateProgress:(GoogleTranslateAPI *)aGoogleTranslateAPI message:(NSString *)message
{
    notificationLabel.text = message;
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
}
- (void)translateDidFinished:(GoogleTranslateAPI *)aGoogleTranslateAPI text:(NSString *)text
{
    translateTextView.text = text;
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissModalViewControllerAnimated:YES];

    imageView.image = image;
    [imageView setNeedsDisplay];

    [activityIndicatorView startAnimating];
    notificationLabel.hidden = NO;

    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        notificationLabel.text = @"UIImageWriteToSavedPhotosAlbum start...";
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }

    notificationLabel.text = @"Writing to JPEG file...";

    NSData * data = UIImageJPEGRepresentation(image, 0.2);
    NSString *docdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString *imagefile = [[docdir stringByAppendingPathComponent:@"image.jpg"] copy];
    NSError * error = nil;
    if(![data writeToFile:imagefile options:0 error:&error]){
        NSLog(@"writeToFile: %@, %@", error, [error userInfo]);
    }
    // [data writeToFile:imagefile atomically:YES];    
    //[data release]; data = nil;

    notificationLabel.text = @"Written to JPEG file.";

    
    // int pages = [aOCRWebService OCRWebServiceAvailablePages];
    // NSLog(@"pages=%d", pages);
    [aOCRWebService OCRWebServiceRecognize:imagefile ocrLanguage:@"FINNISH" outputDocumentFormat:@"TXT" delegate:self];
}



- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0){
        /* Cancel button */
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = [[actionSheetButtonIndex2sourceType objectAtIndex:buttonIndex-1] intValue];
    imagePicker.delegate = self;
    
    [actionSheetButtonIndex2sourceType release];
    actionSheetButtonIndex2sourceType = nil;
    
    [self presentModalViewController:imagePicker animated:YES];
}
- (IBAction)openPhoto:(id)sender {
    actionSheetButtonIndex2sourceType = [[NSMutableArray alloc] init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            [sheet addButtonWithTitle:@"Camera"];
            [actionSheetButtonIndex2sourceType addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            [sheet addButtonWithTitle:@"PhotoLibrary"];
            [actionSheetButtonIndex2sourceType addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
        }
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]){
            [sheet addButtonWithTitle:@"SavedPhotoAlbum"];
            [actionSheetButtonIndex2sourceType addObject:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeSavedPhotosAlbum]];
        }
        [sheet showFromToolbar:toolbar];
        [sheet release]; sheet = nil;
    }else{
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        if(!popover){
            popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else{
            [popover dismissPopoverAnimated:YES];
            [popover release]; popover = nil;
        }
    }
}

@end
























