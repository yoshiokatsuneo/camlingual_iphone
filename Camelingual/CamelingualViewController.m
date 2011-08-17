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
@synthesize sourceLangTableView;
@synthesize destLangTableView;
@synthesize sourceLangLabel;
@synthesize destLangLabel;
@synthesize langSelectView;
@synthesize mainView;
@synthesize aOCRTextViewController;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    sourceLangArray = [[NSArray alloc] initWithObjects:@"BRAZILIAN", @"BULGARIAN", @"BYELORUSSIAN", @"CATALAN", @"CROATIAN", @"CZECH", @"DANISH", @"DUTCH", @"ENGLISH", @"ESTONIAN", @"FINNISH", @"FRENCH", @"GERMAN", @"GREEK", @"HUNGARIAN", @"INDONESIAN", @"ITALIAN", @"LATIN", @"LATVIAN", @"LITHUANIAN", @"MOLDAVIAN", @"POLISH", @"PORTUGUESE", @"ROMANIAN", @"RUSSIAN", @"SERBIAN", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWEDISH", @"TURKISH", @"UKRAINIAN", nil];
    destLangArray = [[NSArray alloc] initWithObjects:@"AFRIKAANS", @"ALBANIAN", @"AMHARIC", @"ARABIC", @"ARMENIAN", @"AZERBAIJANI", @"BASQUE", @"BELARUSIAN", @"BENGALI", @"BIHARI", @"BULGARIAN", @"BURMESE", @"CATALAN", @"CHEROKEE", @"CHINESE", @"CHINESE_SIMPLIFIED", @"CHINESE_TRADITIONAL", @"CROATIAN", @"CZECH", @"DANISH", @"DHIVEHI", @"DUTCH", @"ENGLISH", @"ESPERANTO", @"ESTONIAN", @"FILIPINO", @"FINNISH", @"FRENCH", @"GALICIAN", @"GEORGIAN", @"GERMAN", @"GREEK", @"GUARANI", @"GUJARATI", @"HEBREW", @"HINDI", @"HUNGARIAN", @"ICELANDIC", @"INDONESIAN", @"INUKTITUT", @"ITALIAN", @"JAPANESE", @"KANNADA", @"KAZAKH", @"KHMER", @"KOREAN", @"KURDISH", @"KYRGYZ", @"LAOTHIAN", @"LATVIAN", @"LITHUANIAN", @"MACEDONIAN", @"MALAY", @"MALAYALAM", @"MALTESE", @"MARATHI", @"MONGOLIAN", @"NEPALI", @"NORWEGIAN", @"ORIYA", @"PASHTO", @"PERSIAN", @"POLISH", @"PORTUGUESE", @"PUNJABI", @"ROMANIAN", @"RUSSIAN", @"SANSKRIT", @"SERBIAN", @"SINDHI", @"SINHALESE", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWAHILI", @"SWEDISH", @"TAJIK", @"TAMIL", @"TAGALOG", @"TELUGU", @"THAI", @"TIBETAN", @"TURKISH", @"UKRAINIAN", @"URDU", @"UZBEK", @"UIGHUR", @"VIETNAMESE", nil];
    
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)reloadLang:(BOOL)fInit;
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    sourceLang = [defaults valueForKey:@"sourceLang"];
    if(!sourceLang){sourceLang = @"FINNISH";}
    destLang = [defaults valueForKey:@"destLang"];
    if(!destLang){destLang = @"ENGLISH";}

    {
        int index = [sourceLangArray indexOfObject:sourceLang];
        NSUInteger indexes[] = {0, index};
        NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:indexes length:2];
        [sourceLangTableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:(fInit?UITableViewScrollPositionMiddle:0)];
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    aOCRWebService = [[OCRWebService alloc] init];
    aOCRWebService.user_name = @"YOSHIOKATSUNEO";
    aOCRWebService.license_code = @"BE21E7D3-1D0A-4405-8465-A547917C333C";
    
    aGoogleTranslateAPI = [[GoogleTranslateAPI alloc] init];
    imagePicker = [[UIImagePickerController alloc] init];

    [self reloadLang:YES];
  //  [destLangTableView selectRowAtIndexPath:[destLangTableView indexPathForCell:[destLangTableView dequeueReusableCellWithIdentifier:destLang]] animated:NO scrollPosition:UITableViewScrollPositionMiddle];;

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
    [self setSourceLangTableView:nil];
    [self setDestLangTableView:nil];
    [self setSourceLangLabel:nil];
    [self setDestLangLabel:nil];
    [self setLangSelectView:nil];
    [self setMainView:nil];
    [self setAOCRTextViewController:nil];
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
    [sourceLangTableView release];
    [destLangTableView release];
    [sourceLangLabel release];
    [destLangLabel release];
    [langSelectView release];
    [mainView release];
    [aOCRTextViewController release];
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
    ocrTextView.text = ocrText;
    [aGoogleTranslateAPI translate:ocrText sourceLang:sourceLang destLang:destLang delegate:self];
    // [self showGoogleTranslatePage:ocrText];
    
    notificationLabel.text = @"Connecting for translation...";
    notificationLabel.hidden = NO;
    progressView.hidden = NO;
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
    translateTextView.text = text;
    notificationLabel.hidden = YES;
    progressView.hidden = YES;
    [activityIndicatorView stopAnimating];
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
    
    
    NSLog(@"calling ocr");
    // int pages = [aOCRWebService OCRWebServiceAvailablePages];
    // NSLog(@"pages=%d", pages);
    [aOCRWebService OCRWebServiceRecognize:imagefile ocrLanguage:sourceLang outputDocumentFormat:@"TXT" delegate:self];
    NSLog(@"%s: end", __FUNCTION__);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    NSLog(@"%s: start", __FUNCTION__);
    NSLog(@"[picker dismissModalViewControllerAnimated:YES]");
    [picker dismissModalViewControllerAnimated:YES];

    NSLog(@"imageview.image=image start");
    imageView.image = image;
    NSLog(@"imageview.image=image ends");
    NSLog(@"[imageView setNeedsDisplay] start");
    [imageView setNeedsDisplay];
    NSLog(@"[imageView setNeedsDisplay] end");

    [activityIndicatorView startAnimating];
    notificationLabel.text = @"";
    notificationLabel.hidden = NO;


    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            NSLog(@"Saving to Camera Roll...");
            notificationLabel.text = @"Saving to Camera Roll...";
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            NSLog(@"Saved to Camera Roll");
        }
        
        notificationLabel.text = @"Writing to JPEG file...";
        
        
        NSLog(@"UIImageJPEGRepresentation start");
        NSData * data = [UIImageJPEGRepresentation(image, 0.2) retain];
        NSLog(@"UIImageJPEGRepresentation end");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self didFinishUIImageJPEGRepresentation:data];
        });
    });
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

    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
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
        [self presentModalViewController:imagePicker animated:YES];
    }else{
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

- (void)didFinishOCRTextViewController:(NSString *)text
{
    [self startTranslate:text];
}
- (IBAction)editOCRText:(id)sender {
    [aOCRTextViewController show:self text:ocrTextView.text delegate:self];
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.ocrTextView resignFirstResponder];
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:[sourceLangLabel superview]];
    NSLog(@"touchbegin at (%f, %f)", pt.x, pt.y);
    if(sourceLangLabel.frame.origin.x <= pt.x && pt.x <= sourceLangLabel.frame.origin.x + sourceLangLabel.frame.size.width && sourceLangLabel.frame.origin.y <= pt.y && pt.y <= destLangLabel.frame.origin.y + destLangLabel.frame.size.height){
        mainView.hidden = ! mainView.hidden;
        langSelectView.hidden = ! langSelectView.hidden;
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
        cell.textLabel.text = lang;
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
























