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
#import "OCRTextViewController.h"

@interface CamelingualViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,OCRWebServiceDelegate, GoogleTranslateAPIDelegate,UITableViewDataSource,UITableViewDelegate,OCRTextViewControllerDelegate> {
    UIWebView *webView;
    UIImageView *imageView;
    UILabel *notificationLabel;
    UIActivityIndicatorView *activityIndicatorView;
    UIProgressView *progressView;
    UITextView *ocrTextView;
    UITextView *translateTextView;
    UITableView *sourceLangTableView;
    UITableView *destLangTableView;
    UILabel *sourceLangLabel;
    UILabel *destLangLabel;
    UIView *langSelectView;
    UIView *mainView;
    OCRTextViewController *aOCRTextViewController;

    
    NSMutableArray *actionSheetButtonIndex2sourceType;
    UIPopoverController *popover;
    UIToolbar *toolbar;

    OCRWebService *aOCRWebService;
    GoogleTranslateAPI *aGoogleTranslateAPI;
    UIImagePickerController *imagePicker;
    
    NSArray *sourceLangArray;
    NSArray *destLangArray;
    
    NSString *sourceLang;
    NSString *destLang;
}

- (IBAction)openPhoto:(id)sender;
- (IBAction)openAlbum:(id)sender;
- (IBAction)editOCRText:(id)sender;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *notificationLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;
@property (nonatomic, retain) IBOutlet UITextView *ocrTextView;
@property (nonatomic, retain) IBOutlet UITextView *translateTextView;
@property (nonatomic, retain) IBOutlet UITableView *sourceLangTableView;
@property (nonatomic, retain) IBOutlet UITableView *destLangTableView;
@property (nonatomic, retain) IBOutlet UILabel *sourceLangLabel;
@property (nonatomic, retain) IBOutlet UILabel *destLangLabel;
@property (nonatomic, retain) IBOutlet UIView *langSelectView;
@property (nonatomic, retain) IBOutlet UIView *mainView;
@property (nonatomic, retain) IBOutlet OCRTextViewController *aOCRTextViewController;

@end
