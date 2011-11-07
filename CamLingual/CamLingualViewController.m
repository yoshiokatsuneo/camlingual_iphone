//
//  CamLingualViewController.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamLingualViewController.h"
#import "OCRWebService.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSMutableDictionary+ImageMetadata.h"
#import "Langcodes.h"
#import "CamLingualAppDelegate.h"

@implementation CamLingualViewController
@synthesize toolbar;
@synthesize webView;
@synthesize imageView;
@synthesize imageButton;
@synthesize notificationLabel;
@synthesize notificationLabel2;
@synthesize activityIndicatorView;
@synthesize progressView;
@synthesize ocrTextView;
@synthesize translateTextView;
@synthesize sourceLangTableView;
@synthesize destLangTableView;
@synthesize sourceLangLabel;
@synthesize destLangLabel;
@synthesize mainView;
@synthesize topView;
@synthesize translateView;
@synthesize aOCRTextViewController;
@synthesize photoButton;
@synthesize albumButton;


@synthesize ocrText = _ocrText;
@synthesize translateText = _translateText;
@synthesize image = _image;
@synthesize imageCropRect;
@synthesize imagemetadata = _imagemetadata;
@synthesize cropImage = _cropImage;

@synthesize imageCropViewController;
@synthesize cameraToolbarController;
@synthesize languageSelectController;
@synthesize sourceLang = _sourceLang;
@synthesize destLang = _destLang;

- (NSDictionary*)dictionaryFromPlistInSettingsBundle:(NSString*)plistFile
{
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsBundlePath = [bundlePath stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistPath = [settingsBundlePath stringByAppendingPathComponent:plistFile];
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath    ];
    return settingsDictionary;
}
- (void)loadOCRWebServiceAccountFromBundle
{
    NSDictionary *settingsDictionary = [self dictionaryFromPlistInSettingsBundle:@"OCRWebServiceAccount.plist"];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    for (NSDictionary *item in preferencesArray) {
        NSString *key = [item objectForKey:@"Key"];
        id defaultValue = [item objectForKey:@"DefaultValue"];
        if([key isEqual:@"user_name"]){
            aOCRWebService.user_name = defaultValue;
        }else if([key isEqual:@"license_code"]){
            aOCRWebService.license_code = defaultValue;
        }else if([key isEqual:@"services_url"]){
            aOCRWebService.services_url = defaultValue;
        }
    }    
}
- (void)loadGoogleTranslateAPIAccountFromBundle
{
    NSDictionary *settingsDictionary = [self dictionaryFromPlistInSettingsBundle:@"GoogleTranslateAPI.plist"];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    for(NSDictionary *item in preferencesArray){
        NSString *key = [item objectForKey:@"Key"];
        id defaultValue = [item objectForKey:@"DefaultValue"];
        if([key isEqual:@"API_key"]){
            aGoogleTranslateAPI.API_key = defaultValue;
        }
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    
    aOCRWebService = [[OCRWebService alloc] init];
    [self loadOCRWebServiceAccountFromBundle];  
    // aOCRWebService.user_name = @"xxxxx";
    // aOCRWebService.license_code = @"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX";
    
    aGoogleTranslateAPI = [[GoogleTranslateAPI alloc] init];
    [self loadGoogleTranslateAPIAccountFromBundle];
    // aGoogleTranslateAPI.API_key = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        imagePickerCamera = [[UIImagePickerController alloc] init];
        imagePickerCamera.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerCamera.delegate = self;
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        imagePickerPhoto = [[UIImagePickerController alloc] init];
        imagePickerPhoto.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerPhoto.delegate = self;
    }

    currentView = LANG_SELECT_VIEW;
    self.ocrText = @"Here is OCR text";
    self.translateText = @"Here is translate text";
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    cameraToolbarController = [[CameraToolbarController alloc] init];

    self.imageCropRect = CGRectMake(0, 0, 1.0, 1.0);
    
    langcodes = [[Langcodes alloc] init];
    
    ticketManager = [[TicketManager alloc] init];
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"locationManager:didUpdateToLocation:%@ fromLocation:%@", newLocation, oldLocation);
}
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"locationManager:didUpdateHeading:%@", newHeading);
}
- (void)reloadLang:(BOOL)fInit;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.sourceLang = [defaults valueForKey:@"sourceLang"];
    self.destLang = [defaults valueForKey:@"destLang"];
    if(! [languageSelectController.sourceLangArray containsObject:self.sourceLang]){
        self.sourceLang = nil;        
    }
    if(! [languageSelectController.destLangArray containsObject:self.destLang]){
        self.destLang = nil;        
    }
    if(!self.destLang){self.destLang = @"ENGLISH";}

    if(self.sourceLang){
        photoButton.enabled = YES;
        albumButton.enabled = YES;
    }else{
        photoButton.enabled = NO;
        albumButton.enabled = NO;
    }
    
    sourceLangLabel.text = [langcodes threeletterFromLang:self.sourceLang];
    destLangLabel.text = [langcodes threeletterFromLang:self.destLang];
    
    [languageSelectController setLanguageSource:self.sourceLang dest:self.destLang];
}
-(void)didChangeLanguage:(id)sender sourceLang:(NSString *)sourceLang destLang:(NSString *)destLang
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(sourceLang){
        [defaults setValue:sourceLang forKey:@"sourceLang"];
    }
    if(destLang){
        [defaults setValue:destLang forKey:@"destLang"];
    }    
    [self reloadLang:NO];
}
- (void)reloadView
{
    languageSelectController.view.hidden = !(currentView == LANG_SELECT_VIEW);
    mainView.hidden = translateView.hidden = !(currentView == TRANSLATE_VIEW);
    languageSelectController.delegate = self;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    languageSelectController.view.frame = self.mainView.frame;
    [self.view insertSubview:languageSelectController.view atIndex:0];
    
    [self reloadView];    
    [self reloadLang:YES];
    
    self.imageView.image = self.cropImage;
    [self.imageButton setImage:self.cropImage forState:UIControlStateNormal];
    ocrTextView.text = self.ocrText;
    translateTextView.text = self.translateText;

    NSLog(@"viewController=%@", self.navigationController);
    NSLog(@"viewController.controllers=%@", self.navigationController.viewControllers);
}

- (void)viewDidUnload
{
    
    [self setWebView:nil];
    [self setImageView:nil];
    [self setToolbar:nil];
    [self setNotificationLabel:nil];
    [self setActivityIndicatorView:nil];
    [self setProgressView:nil];
    [self setOcrTextView:nil];
    [self setTranslateTextView:nil];
    [self setSourceLangTableView:nil];
    [self setDestLangTableView:nil];
    [self setSourceLangLabel:nil];
    [self setDestLangLabel:nil];
    [self setMainView:nil];
    [self setAOCRTextViewController:nil];
    [self setPhotoButton:nil];
    [self setAlbumButton:nil];
    [self setImageCropViewController:nil];
    [self setTopView:nil];
    [self setImageButton:nil];
    [self setLanguageSelectController:nil];
    [self setTranslateView:nil];
    [self setNotificationLabel2:nil];
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
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    sleep(0);
}

- (void)dealloc {
    [aOCRWebService release]; aOCRWebService = nil;
    [aGoogleTranslateAPI release]; aGoogleTranslateAPI = nil;
    [ticketManager release]; ticketManager = nil;

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
    [sourceLangTableView release];
    [destLangTableView release];
    [sourceLangLabel release];
    [destLangLabel release];
    [mainView release];
    [aOCRTextViewController release];
    [photoButton release];
    [albumButton release];

    
    [imageCropViewController release];
    [topView release];
    
    self.cameraToolbarController = nil;
    [imageButton release];
    [languageSelectController release];
    [translateView release];
    [notificationLabel2 release];
    
    
    [super dealloc];
}

- (void)errorAlert:(NSError*)error
{
    NSLog(@"%s: localizedDescription:%@, userInfo:%@", __FUNCTION__, [error localizedDescription], [error userInfo]);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}
- (void)alert:(NSString*)message
{
    NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:message forKey:NSLocalizedDescriptionKey]];
    [self errorAlert:error];
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
    [request setValue:@"CamLingual" forHTTPHeaderField:@"User_Agent"];
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
-(void)startTranslate:(NSString*)ocrText
{
    NSLog(@"%s: start", __FUNCTION__);
    ocrTextView.text = self.ocrText = ocrText;
    
    NSString * sourceLang = self.sourceLang;
    if([ocrText isEqual:@"No recognized text !"]){
        sourceLang = @"ENGLISH";
        fNeedConsumeTicket = NO;
    }
    
    [aGoogleTranslateAPI translate:ocrText sourceLang:sourceLang destLang:self.destLang delegate:self];
    // [self showGoogleTranslatePage:ocrText];
    destStartLang = self.destLang;
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"Connecting for translation...";
    notificationLabel.hidden = NO;
    progressView.hidden = YES;
    NSLog(@"%s: end", __FUNCTION__);
    
}
/**
 Sometimes, a words is splitted to multiple lines using "-"
 */
- adjustText: (NSString*)text
{
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"(\\p{Latin}\\p{Latin})-(\\p{Latin}\\p{Latin})" options:0 error:nil];
    NSString *replaced = [regexp stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@"$1$2"];
    NSLog(@"%s: input: %@", __FUNCTION__, text);
    NSLog(@"%s: output: %@", __FUNCTION__, replaced);
    return replaced;
}

-(void)OCRWebServiceDidFinish:(OCRWebService *)aOCRWebService ocrText:(NSString*)ocrText;
{
    NSString *adjustText = [self adjustText:ocrText];
    [self startTranslate:adjustText];
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
    notificationLabel.hidden = NO;
    progressView.hidden = NO;
}

- (void)translateDidFinished:(GoogleTranslateAPI *)aGoogleTranslateAPI text:(NSString *)text
{
    sourceDoneLang = sourceStartLang;
    destDoneLang = destStartLang;
    
    translateTextView.text = self.translateText = text;
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
    [activityIndicatorView stopAnimating];
    if(fNeedConsumeTicket){
        ticketManager.usedTickets = ticketManager.usedTickets + 1;
        ticketManager.availableTickets = ticketManager.availableTickets - 1;
        fNeedConsumeTicket = NO;
    }
}
- (void)writeImageToSavedPhotoAlbum
{
    if(locationManager){
        [self.imagemetadata setLocation:locationManager.location];
    }
    
    [locationManager stopUpdatingLocation];
    
    NSLog(@"Saving to Camera Roll...");
    notificationLabel2.text = @"Saving to Camera Roll...";
    notificationLabel2.hidden = NO;
    
    ALAssetsLibrary *alalib = [[ALAssetsLibrary alloc] init];
    NSLog(@"writeImageToSavedPhotosAlbum start");
    [alalib writeImageToSavedPhotosAlbum:(self.image.CGImage) metadata:self.imagemetadata completionBlock:^(NSURL *assetURL, NSError *error){
        NSLog(@"completionBlock:%@:%@", assetURL, error);
        notificationLabel2.hidden = YES;
    }];
    NSLog(@"writeImageToSavedPhotosAlbum end");
    [alalib release];
    
}
- (void)startOCR
{
    NSLog(@"calling ocr");
    
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"Connecting for OCR...";
    notificationLabel.hidden = NO;
    progressView.hidden = YES;
    
    NSString *docdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString *imagefile = [docdir stringByAppendingPathComponent:@"image.jpg"];
    [aOCRWebService OCRWebServiceRecognize:imagefile ocrLanguage:self.sourceLang outputDocumentFormat:@"TXT" delegate:self];
    sourceStartLang = self.sourceLang;
    NSLog(@"%s: end", __FUNCTION__);
    
}
- (void)didFinishUIImageJPEGRepresentation:(NSData*)data
{
    NSLog(@"%s: start", __FUNCTION__);
    NSString *docdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString *imagefile = [docdir stringByAppendingPathComponent:@"image.jpg"];
    NSError * error = nil;
    NSLog(@"writeToFile start");
    if(![data writeToFile:imagefile options:0 error:&error]){
        NSLog(@"writeToFile: %@, %@", error, [error userInfo]);
    }
    [data release]; data = nil;
    NSLog(@"writeToFile end");
    
    notificationLabel.text = @"Written to JPEG file.";
    
    [self startOCR];
    if(f_needWriteImageToSavedPhotoAlbum){
        [self writeImageToSavedPhotoAlbum];
        f_needWriteImageToSavedPhotoAlbum = NO;
    }
    NSLog(@"%s: end", __FUNCTION__);
}

- (void)asyncWriteToJpeg
{
    notificationLabel.text = @"Writing to JPEG file...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"UIImageJPEGRepresentation start");
        NSData * data = [UIImageJPEGRepresentation(self.cropImage, 0.2) retain];
        NSLog(@"UIImageJPEGRepresentation end");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didFinishUIImageJPEGRepresentation:data];
        });
    });
}

-(void)didCancelImageCropViewController:(id)sender
{
    ((ImageCropViewController*)sender).view.window.rootViewController = self;
    
    if(f_imageCropAsPreview){
        if(imagePicker == imagePickerCamera){
            [self openPhoto:self];
        }else{
            [self openAlbum:self];
        }
    }
}
-(void)didFinishImageCropViewController:(id)sender cropImage:(UIImage *)cropImage cropRect:(CGRect)cropRect;
{
    
    ((ImageCropViewController*)sender).view.window.rootViewController = self;

    self.imageView.image = self.cropImage = cropImage;
    [self.imageButton setImage:self.cropImage forState:UIControlStateNormal];
    self.imageCropRect = cropRect;
    [self.imageView setNeedsDisplay];
    
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"";
    notificationLabel.hidden = NO;
    
    if(f_imageCropAsPreview && imagePicker == imagePickerCamera){
        f_needWriteImageToSavedPhotoAlbum = YES;        
    }
    [self asyncWriteToJpeg];
}



- (void)dumpview:(UIView*)view count:(int)count
{
    int index = 0;
    NSLog(@"dumpview(%d): view=%@, class=%@", count, view, [view class]);
    for (UIView *v in view.subviews){
        NSLog(@"index:%d", index);
        [self dumpview:v count:count+1];
        index++;
    }
}
- (void)dumpitems:(NSArray*)items count:(int)count
{
    NSLog(@"dumpitems(%d): o=%@, class=%@", count, items, [items class]);
    for (NSObject *o in items){
        if([items isKindOfClass:[NSArray class]]){
            [self dumpitems:(NSArray*)o count:count+1];
        }else{
            NSLog(@"dumpitems-item(%d): o=%@, class=%@", count, o, [o class]);
        }
    }
}
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"willShowViewController:%@, %@, %@", viewController, viewController.toolbarItems, viewController.tabBarItem);
}
-(void)captureButtonAction:(id)sender
{
    imagePickerCamera.showsCameraControls = NO;
    [imagePickerCamera takePicture];
}
-(void)skipPreviewInImagePickerCamera:(UIViewController*)viewController;
{
    /* Skip capture page */
    NSString * systemVer = [[UIDevice currentDevice] systemVersion];
    NSArray * verArray = [systemVer componentsSeparatedByString:@"."];
    int majorver = [[verArray objectAtIndex:0] intValue];
    
    // [self dumpview:viewController.view count:0];
    UIButton *button = nil; /*  PLCameraView = PLCropOverlay = PLCropOverlayBottomBar = UIImageView = PLCameraButton */
    if(majorver >= 5){
        UIView *view = viewController.view;
        int index;
        
        index = 3;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}
        
        index = 1;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}
        
        index = 1;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}
        
        index = 0;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}
        
        if(![view isKindOfClass:[UIButton class]]){return;}
        button = (UIButton*)view;
    
    }else{
        UIView *view = viewController.view;
        int index;
        
        index = 2;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}

        index = 1;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}

        index = 1;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}

        index = 0;
        if(view.subviews.count<=index){return;}
        view = [view.subviews objectAtIndex:index];
        if(![view isKindOfClass:[UIView class]]){return;}
        
        if(![view isKindOfClass:[UIButton class]]){return;}
        button = (UIButton*)view;
    }
    id target = [[button allTargets] anyObject];
    NSString *str = [[button actionsForTarget:target forControlEvent:UIControlEventTouchUpInside] objectAtIndex:0];
    SEL action = NSSelectorFromString(str);
    [button removeTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"%s start:%@, %@, %@ ============================ ", __FUNCTION__, viewController, viewController.toolbarItems, viewController.tabBarItem);
    if(imagePicker == imagePickerCamera){
        [self skipPreviewInImagePickerCamera:viewController];
    }
    NSLog(@"%s end:%@, %@, %@ ============================ ", __FUNCTION__, viewController, viewController.toolbarItems, viewController.tabBarItem);
    sleep(0);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [locationManager stopUpdatingLocation];  
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    currentView = TRANSLATE_VIEW;
    [self reloadView];
    
    ocrTextView.text = self.ocrText = @"";
    translateTextView.text = self.translateText = @"";
    fNeedConsumeTicket = TRUE;
    
    NSLog(@"%s: start", __FUNCTION__);
    NSLog(@"[picker dismissModalViewControllerAnimated:YES]");
    [picker dismissModalViewControllerAnimated:NO];
    [popover dismissPopoverAnimated:NO];
    
    NSLog(@"imageview.image=image start");
    UIImage *image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = self.image = self.cropImage= image;
    [self.imageButton setImage:self.cropImage forState:UIControlStateNormal];
    
    self.imageCropRect = CGRectMake(0, 0, 1.0, 1.0);
    NSLog(@"imageview.image=image ends");
    NSLog(@"[imageView setNeedsDisplay] start");
    [imageView setNeedsDisplay];
    NSLog(@"[imageView setNeedsDisplay] end");

    NSLog(@"editingInfo=[%@]", info);
    self.imagemetadata = (NSMutableDictionary*)[info objectForKey:UIImagePickerControllerMediaMetadata];
    NSLog(@"metadata=[%@]", self.imagemetadata);

    f_imageCropAsPreview = YES;
    [imageCropViewController show:self image:self.image cropRect:self.imageCropRect delegate:self];

    NSLog(@"%s: end", __FUNCTION__);
}


- (IBAction)openPhoto:(id)sender {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [self alert:@"Camera is not supportted in this device."];    
        return;
    }
    if([ticketManager availableTickets]<=0){
        [ticketManager inAppPurchase:self action:@selector(openPhoto:) sender:sender];
        return;
    }
    
    [locationManager startUpdatingLocation];
    imagePicker = imagePickerCamera;
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)openAlbum:(id)sender {
    if([ticketManager availableTickets]<=0){
        [ticketManager inAppPurchase:self action:@selector(openAlbum:) sender:sender];
        return;
    }

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            [self alert:@"PhotoLibrary is not supportted in this device."];
            return;
        }
        imagePicker = imagePickerPhoto;
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        if(!popover){
            imagePicker = imagePickerPhoto;
            popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
            [popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }else{
            [popover dismissPopoverAnimated:YES];
            [popover release]; popover = nil;
        }
    }
}
- (void)didFinishOCRTextViewController:(NSString *)text
{
    [self startTranslate:text];
}
- (IBAction)editOCRText:(id)sender {
    [aOCRTextViewController show:self text:ocrTextView.text delegate:self];
    
}

- (IBAction)cropImage:(id)sender {
    f_imageCropAsPreview = NO;
    [imageCropViewController show:self image:self.image cropRect:self.imageCropRect delegate:self];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.ocrTextView resignFirstResponder];
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:[sourceLangLabel superview]];
    // NSLog(@"touchbegin at (%f, %f)", pt.x, pt.y);
    if(self.sourceLang && sourceLangLabel.frame.origin.x <= pt.x && pt.x <= sourceLangLabel.frame.origin.x + sourceLangLabel.frame.size.width && sourceLangLabel.frame.origin.y <= pt.y && pt.y <= destLangLabel.frame.origin.y + destLangLabel.frame.size.height){
        if(currentView == TRANSLATE_VIEW){
            currentView = LANG_SELECT_VIEW;
        }else{
            currentView = TRANSLATE_VIEW;
        }
        [self reloadView];

        if(! translateView.hidden){
            if(self.cropImage && ![sourceDoneLang isEqual:self.sourceLang]){
                [self startOCR];
            }else if(![destDoneLang isEqual:self.destLang]){
                [self startTranslate:ocrTextView.text];
            }
        }
    }
}




@end
























