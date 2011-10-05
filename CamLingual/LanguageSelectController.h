//
//  LanguageSelectController.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LanguageSelectControllerDelegate;

@interface LanguageSelectController : UIViewController<UITableViewDataSource,UITableViewDelegate> {
    UITableView *sourceLangTableView;
    UITableView *destLangTableView;

    NSArray *sourceLangArray;
    NSArray *destLangArray;
    
}
- (void)setLanguageSource:(NSString*)sourceLang dest:(NSString*)destLang;


@property (nonatomic, retain) IBOutlet UITableView *sourceLangTableView;
@property (nonatomic, retain) IBOutlet UITableView *destLangTableView;
@property (retain) id<LanguageSelectControllerDelegate> delegate;
@property (retain) NSArray *sourceLangArray;
@property (retain) NSArray *destLangArray;
@end

@protocol LanguageSelectControllerDelegate <NSObject>
- (void)didChangeLanguage:(id)sender sourceLang:(NSString*)sourceLang destLang:(NSString*)destLang;
@end
