//
//  CamelingualViewController.h
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCRWebService.h"
#import "GoogleTranslateAPI.h"

@interface CamelingualViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,OCRWebServiceDelegate, GoogleTranslateAPIDelegate> {
    UIWebView *webView;
    UIImageView *imageView;
    UILabel *notificationLabel;
    UIActivityIndicatorView *activityIndicatorView;
    UIProgressView *progressView;
    UITextView *ocrTextView;
    UITextView *translateTextView;
    
    NSMutableArray *actionSheetButtonIndex2sourceType;
    UIPopoverController *popover;
    UIToolbar *toolbar;

    OCRWebService *aOCRWebService;
    GoogleTranslateAPI *aGoogleTranslateAPI;
    UIImagePickerController *imagePicker;
}

- (IBAction)openPhoto:(id)sender;
- (IBAction)openAlbum:(id)sender;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *notificationLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UITextView *ocrTextView;
@property (nonatomic, retain) IBOutlet UITextView *translateTextView;

@end
