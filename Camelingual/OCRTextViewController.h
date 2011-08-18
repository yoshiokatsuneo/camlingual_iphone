//
//  OCRTextViewController.h
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OCRTextViewControllerDelegate;

@interface OCRTextViewController : UIViewController {
    UITextView *textView;
}


- (void)show:(UIViewController*)parent text:(NSString*)text  delegate:(id<OCRTextViewControllerDelegate>)delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (retain) id<OCRTextViewControllerDelegate> delegate;
@end

@protocol OCRTextViewControllerDelegate <NSObject>
- (void)didFinishOCRTextViewController:(NSString*)text;
@end
