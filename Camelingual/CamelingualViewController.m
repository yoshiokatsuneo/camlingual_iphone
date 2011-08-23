//
//  CamelingualViewController.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CamelingualViewController.h"
#import "OCRWebService.h"
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSMutableDictionary+ImageMetadata.h"


@implementation CamelingualViewController
@synthesize toolbar;
@synthesize webView;
@synthesize imageView;
@synthesize notificationLabel;
@synthesize activityIndicatorView;
@synthesize progressView;
@synthesize ocrTextView;
@synthesize translateTextView;
@synthesize sourceLangTableView;
@synthesize destLangTableView;
@synthesize sourceLangLabel;
@synthesize destLangLabel;
@synthesize langSelectView;
@synthesize mainView;
@synthesize topView;
@synthesize aOCRTextViewController;
@synthesize photoButton;
@synthesize albumButton;


@synthesize ocrText = _ocrText;
@synthesize translateText = _translateText;
@synthesize image = _image;
@synthesize imagemetadata = _imagemetadata;
@synthesize cropImage = _cropImage;

@synthesize imageCropViewController;
@synthesize cameraToolbarController;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    sourceLangArray = [[NSArray alloc] initWithObjects:@"BRAZILIAN", @"BULGARIAN", @"BYELORUSSIAN", @"CATALAN", @"CROATIAN", @"CZECH", @"DANISH", @"DUTCH", @"ENGLISH", @"ESTONIAN", @"FINNISH", @"FRENCH", @"GERMAN", @"GREEK", @"HUNGARIAN", @"INDONESIAN", @"ITALIAN", @"LATIN", @"LATVIAN", @"LITHUANIAN", @"MOLDAVIAN", @"POLISH", @"PORTUGUESE", @"ROMANIAN", @"RUSSIAN", @"SERBIAN", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWEDISH", @"TURKISH", @"UKRAINIAN", nil];
    destLangArray = [[NSArray alloc] initWithObjects:@"AFRIKAANS", @"ALBANIAN", @"AMHARIC", @"ARABIC", @"ARMENIAN", @"AZERBAIJANI", @"BASQUE", @"BELARUSIAN", @"BENGALI", @"BIHARI", @"BULGARIAN", @"BURMESE", @"CATALAN", @"CHEROKEE", @"CHINESE", @"CHINESE_SIMPLIFIED", @"CHINESE_TRADITIONAL", @"CROATIAN", @"CZECH", @"DANISH", @"DHIVEHI", @"DUTCH", @"ENGLISH", @"ESPERANTO", @"ESTONIAN", @"FILIPINO", @"FINNISH", @"FRENCH", @"GALICIAN", @"GEORGIAN", @"GERMAN", @"GREEK", @"GUARANI", @"GUJARATI", @"HEBREW", @"HINDI", @"HUNGARIAN", @"ICELANDIC", @"INDONESIAN", @"INUKTITUT", @"ITALIAN", @"JAPANESE", @"KANNADA", @"KAZAKH", @"KHMER", @"KOREAN", @"KURDISH", @"KYRGYZ", @"LAOTHIAN", @"LATVIAN", @"LITHUANIAN", @"MACEDONIAN", @"MALAY", @"MALAYALAM", @"MALTESE", @"MARATHI", @"MONGOLIAN", @"NEPALI", @"NORWEGIAN", @"ORIYA", @"PASHTO", @"PERSIAN", @"POLISH", @"PORTUGUESE", @"PUNJABI", @"ROMANIAN", @"RUSSIAN", @"SANSKRIT", @"SERBIAN", @"SINDHI", @"SINHALESE", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWAHILI", @"SWEDISH", @"TAJIK", @"TAMIL", @"TAGALOG", @"TELUGU", @"THAI", @"TIBETAN", @"TURKISH", @"UKRAINIAN", @"URDU", @"UZBEK", @"UIGHUR", @"VIETNAMESE", nil];
    
    aOCRWebService = [[OCRWebService alloc] init];
    aOCRWebService.user_name = @"YOSHIOKATSUNEO";
    aOCRWebService.license_code = @"BE21E7D3-1D0A-4405-8465-A547917C333C";
    
    aGoogleTranslateAPI = [[GoogleTranslateAPI alloc] init];
    imagePicker = [[UIImagePickerController alloc] init];

    currentView = LANG_SELECT_VIEW;
    self.ocrText = @"Here is OCR text";
    self.translateText = @"Here is translate text";
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    cameraToolbarController = [[CameraToolbarController alloc] init];

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
    
    sourceLang = [defaults valueForKey:@"sourceLang"];
    destLang = [defaults valueForKey:@"destLang"];
    if(!destLang){destLang = @"ENGLISH";}

    if(sourceLang){
        int index = [sourceLangArray indexOfObject:sourceLang];
        NSUInteger indexes[] = {0, index};
        NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:indexes length:2];
        [sourceLangTableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:(fInit?UITableViewScrollPositionMiddle:0)];
        photoButton.enabled = YES;
        albumButton.enabled = YES;
    }else{
        photoButton.enabled = NO;
        albumButton.enabled = NO;
    }
    
    {
        int index = [destLangArray indexOfObject:destLang];
        NSUInteger indexes[] = {0, index};
        NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:indexes length:2];
        [destLangTableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:(fInit?UITableViewScrollPositionMiddle:0)];
    }
    
    sourceLangLabel.text = [sourceLang substringToIndex:3];
    destLangLabel.text = [destLang substringToIndex:3];
}
- (void)reloadView
{
    mainView.hidden = !(currentView == MAIN_VIEW);
    langSelectView.hidden = !(currentView == LANG_SELECT_VIEW);
    
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self reloadView];    
    [self reloadLang:YES];
    
    imageView.image = self.cropImage;
    ocrTextView.text = self.ocrText;
    translateTextView.text = self.translateText;

    
    
  //  [destLangTableView selectRowAtIndexPath:[destLangTableView indexPathForCell:[destLangTableView dequeueReusableCellWithIdentifier:destLang]] animated:NO scrollPosition:UITableViewScrollPositionMiddle];;

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
    [self setLangSelectView:nil];
    [self setMainView:nil];
    [self setAOCRTextViewController:nil];
    [self setPhotoButton:nil];
    [self setAlbumButton:nil];
    [self setImageCropViewController:nil];
    [self setTopView:nil];
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
    [aOCRWebService release]; aOCRWebService = nil;
    [aGoogleTranslateAPI release]; aGoogleTranslateAPI = nil;

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
    [langSelectView release];
    [mainView release];
    [aOCRTextViewController release];
    [photoButton release];
    [albumButton release];

    
    [imageCropViewController release];
    [topView release];
    
    self.cameraToolbarController = nil;
    [super dealloc];
}

- (void)errorAlert:(NSError*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[[error userInfo] description] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
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
-(void)startTranslate:(NSString*)ocrText
{
    NSLog(@"%s: start", __FUNCTION__);
    ocrTextView.text = self.ocrText = ocrText;
    
    [aGoogleTranslateAPI translate:ocrText sourceLang:sourceLang destLang:destLang delegate:self];
    // [self showGoogleTranslatePage:ocrText];
    destStartLang = destLang;
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"Connecting for translation...";
    notificationLabel.hidden = NO;
    progressView.hidden = YES;
    NSLog(@"%s: end", __FUNCTION__);
    
}
-(void)OCRWebServiceDidFinish:(OCRWebService *)aOCRWebService ocrText:(NSString*)ocrText;
{
    [self startTranslate:ocrText];
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
}
- (void)startOCR
{
    NSLog(@"calling ocr");
    // int pages = [aOCRWebService OCRWebServiceAvailablePages];
    // NSLog(@"pages=%d", pages);
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"Connecting for OCR...";
    notificationLabel.hidden = NO;
    progressView.hidden = YES;
    
    NSString *docdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString *imagefile = [docdir stringByAppendingPathComponent:@"image.jpg"];
    [aOCRWebService OCRWebServiceRecognize:imagefile ocrLanguage:sourceLang outputDocumentFormat:@"TXT" delegate:self];
    sourceStartLang = sourceLang;
    NSLog(@"%s: end", __FUNCTION__);
    
}
- (void)didFinishUIImageJPEGRepresentation:(NSData*)data
{
    NSLog(@"%s: start", __FUNCTION__);
    NSString *docdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] ;
    NSString *imagefile = [[docdir stringByAppendingPathComponent:@"image.jpg"] copy];
    NSError * error = nil;
    NSLog(@"writeToFile start");
    if(![data writeToFile:imagefile options:0 error:&error]){
        NSLog(@"writeToFile: %@, %@", error, [error userInfo]);
    }
    [data release]; data = nil;
    NSLog(@"writeToFile end");
    
    notificationLabel.text = @"Written to JPEG file.";
    
    [self startOCR];
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
    [self dumpview:[[[viewController.view.subviews objectAtIndex:2] subviews] objectAtIndex:2]  count:0];
    NSLog(@"==========begin===================================================");
    [self dumpitems:viewController.toolbarItems count:0];
    [self dumpview:navigationController.navigationBar count:0];
    NSLog(@"===========end==============================================");
    sleep(0);
}
-(void)captureButtonAction:(id)sender
{
    imagePicker.showsCameraControls = NO;
    [imagePicker takePicture];
    sleep(0);
}
-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSLog(@"willShowViewController:%@, %@, %@", viewController, viewController.toolbarItems, viewController.tabBarItem);
    NSLog(@"====================test1=======================");
    if(imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
        /* Skip capture page */
        UIButton *button = [[[[[[[viewController.view.subviews objectAtIndex:2] subviews] objectAtIndex:2] subviews] objectAtIndex:1] subviews] objectAtIndex:0];
        [self dumpview:button count:0];
        id target = [[button allTargets] anyObject];
        NSString *str = [[button actionsForTarget:target forControlEvent:UIControlEventTouchUpInside] objectAtIndex:0];
        SEL action = NSSelectorFromString(str);
        [button removeTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSLog(@"====================test2=======================");

    [self dumpview:viewController.view count:0];
    NSLog(@"====================test3=======================");
    sleep(0);
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [locationManager stopUpdatingLocation];  
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    currentView = MAIN_VIEW;
    [self reloadView];
    
    ocrTextView.text = self.ocrText = @"";
    translateTextView.text = self.translateText = @"";
    
    NSLog(@"%s: start", __FUNCTION__);
    NSLog(@"[picker dismissModalViewControllerAnimated:YES]");
    [picker dismissModalViewControllerAnimated:NO];

    NSLog(@"imageview.image=image start");
    UIImage *image = (UIImage*)[info objectForKey:UIImagePickerControllerOriginalImage];
    imageView.image = self.image = self.cropImage= image;
    NSLog(@"imageview.image=image ends");
    NSLog(@"[imageView setNeedsDisplay] start");
    [imageView setNeedsDisplay];
    NSLog(@"[imageView setNeedsDisplay] end");

    NSLog(@"editingInfo=[%@]", info);
    self.imagemetadata = (NSMutableDictionary*)[info objectForKey:UIImagePickerControllerMediaMetadata];
    NSLog(@"metadata=[%@]", self.imagemetadata);

    f_imageCropAsPreview = YES;
    [imageCropViewController show:self image:self.image delegate:self];


    
        
        
//    NSLog(@"UIImageJPEGRepresentation start");
//    NSData * data = UIImageJPEGRepresentation(image, 0.2);
//    NSLog(@"UIImageJPEGRepresentation end");
    NSLog(@"%s: end", __FUNCTION__);
}


#if 0
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
#endif

- (IBAction)openPhoto:(id)sender {
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        [self alert:@"Camera is not supportted in this device."];    
        return;
    }

    // [locationManager startUpdatingLocation];
    
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    // imagePicker.showsCameraControls = YES;
    NSLog(@"imagePicker.cameraOverlayView=[%@] subviews=[%@]", imagePicker.cameraOverlayView, imagePicker.cameraOverlayView.subviews);
    cameraToolbarController.view.frame = CGRectMake(0.0, imagePicker.cameraOverlayView.bounds.size.height - 70 /*cameraToolbarController.view.frame.size.height*/, imagePicker.cameraOverlayView.bounds.size.width, cameraToolbarController.view.frame.size.height);
    // [self dumpview:imagePicker.cameraOverlayView count:0];

    
    // [imagePicker.cameraOverlayView insertSubview:cameraToolbarController.view atIndex:imagePicker.cameraOverlayView.subviews.count];
    // imagePicker.showsCameraControls = NO;
     
     
     // insertSubview:<#(UIView *)#> atIndex:<#(NSInteger)#> addSubview: cameraToolbarController.view];
    // imagePicker.cameraOverlayView = imagePickerCropController.view;
    
    [self presentModalViewController:imagePicker animated:YES];
}

- (IBAction)openAlbum:(id)sender {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            [self alert:@"PhotoLibrary is not supportted in this device."];
            return;
        }
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        imagePicker.showsCameraControls = YES;
        [self presentModalViewController:imagePicker animated:YES];
    }else{
        imagePicker.delegate = self;
        imagePicker.showsCameraControls = YES;
        if(!popover){
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

-(void)didCancelImageCropViewController:(id)sender
{
    self.view = self.topView;
    if(f_imageCropAsPreview){
        if(imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
            [self openPhoto:self];
        }else{
            [self openAlbum:self];
        }
    }
}
-(void)didFinishImageCropViewController:(id)sender cropImage:(UIImage *)cropImage
{
    
    self.view = self.topView;
    self.imageView.image = self.cropImage = cropImage;
    [self.imageView setNeedsDisplay];
    
    [activityIndicatorView startAnimating];
    notificationLabel.text = @"";
    notificationLabel.hidden = NO;
    
    
    
    
    
    
    
    if(f_imageCropAsPreview && imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera){
        if(locationManager){
            [self.imagemetadata setLocation:locationManager.location];
        }
        
        [locationManager stopUpdatingLocation];

        NSLog(@"Saving to Camera Roll...");
        notificationLabel.text = @"Saving to Camera Roll...";
        
        ALAssetsLibrary *alalib = [[ALAssetsLibrary alloc] init];
        NSLog(@"writeImageToSavedPhotosAlbum start");
        [alalib writeImageToSavedPhotosAlbum:(self.image.CGImage) metadata:self.imagemetadata completionBlock:^(NSURL *assetURL, NSError *error){
            NSLog(@"completionBlock:%@:%@", assetURL, error);
            [self asyncWriteToJpeg];
            
#if 0
            // NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            [alalib assetForURL:assetURL
                    resultBlock:^(ALAsset *asset) {
                        ALAssetRepresentation *representation = [asset defaultRepresentation];
                        NSDictionary *metadataDict = [representation metadata]; // ←ここにExifとかGPSの情報が入ってる
                        NSLog(@"metadataDict:%@",metadataDict);
                    } failureBlock:^(NSError *error) {
                        NSLog(@"error:%@",error);
                    }];
#endif
            
        }];
        NSLog(@"writeImageToSavedPhotosAlbum end");
        [alalib release];
        // UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }else{
        [self asyncWriteToJpeg];
    }
    
    
    
    
    
    
    [self asyncWriteToJpeg];
}
- (IBAction)cropImage:(id)sender {
    f_imageCropAsPreview = NO;
    [imageCropViewController show:self image:self.image delegate:self];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.ocrTextView resignFirstResponder];
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:[sourceLangLabel superview]];
    // NSLog(@"touchbegin at (%f, %f)", pt.x, pt.y);
    if(sourceLang && sourceLangLabel.frame.origin.x <= pt.x && pt.x <= sourceLangLabel.frame.origin.x + sourceLangLabel.frame.size.width && sourceLangLabel.frame.origin.y <= pt.y && pt.y <= destLangLabel.frame.origin.y + destLangLabel.frame.size.height){
        if(currentView == MAIN_VIEW){
            currentView = LANG_SELECT_VIEW;
        }else{
            currentView = MAIN_VIEW;
        }
        [self reloadView];

        if(mainView.hidden == NO){
            if(imageView.image && ![sourceDoneLang isEqual:sourceLang]){
                [self startOCR];
            }else if(![destDoneLang isEqual:destLang]){
                [self startTranslate:ocrTextView.text];
            }
        }
    }
}
-(NSArray*)tableViewToArray:(UITableView*)tableView
{
    if(tableView == sourceLangTableView){
        return sourceLangArray;
    }else if(tableView == destLangTableView){
        return destLangArray;
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath indexAtPosition:1];
    NSArray * array = [self tableViewToArray:tableView];
    NSString *lang = [array objectAtIndex:index];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lang];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lang] autorelease];
        cell.textLabel.text = [[lang substringToIndex:1] stringByAppendingString:[[lang substringFromIndex:1] lowercaseString]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath indexAtPosition:1];
    NSArray *array = [self tableViewToArray:tableView];
    NSString *lang = [array objectAtIndex:index];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(tableView == sourceLangTableView){
        [defaults setValue:lang forKey:@"sourceLang"];
    }else if(tableView == destLangTableView){
        [defaults setValue:lang forKey:@"destLang"];
    }

    [self reloadLang:NO];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(tableView == sourceLangTableView){
        count =  [sourceLangArray count];
    }else if(tableView == destLangTableView){
        count =  [destLangArray count];
    }
    return count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == sourceLangTableView){
        return @"From";
    }else if(tableView == destLangTableView){
        return @"To";
    }
    return nil;
}




@end
























