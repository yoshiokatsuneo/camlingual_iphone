//
//  GoogleTranslateAPI.h
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol GoogleTranslateAPIDelegate;

@interface GoogleTranslateAPI : NSObject
{
    NSMutableData *responsebodydata;
    NSMutableDictionary *langdic;
}
- (BOOL)translate:(NSString*)string  sourceLang:(NSString*)sourceLang destLang:(NSString*)destLang delegate:(id<GoogleTranslateAPIDelegate>)delegate;

@property(retain) id<GoogleTranslateAPIDelegate> delegate;
@property(retain) NSURLConnection *connection;
@end

@protocol GoogleTranslateAPIDelegate <NSObject>

- (void)translateDidFinished:(GoogleTranslateAPI*)aGoogleTranslateAPI text:(NSString*)text;
- (void)translate:(GoogleTranslateAPI*)aGoogleTranslateAPI didFailWithError:(NSError*)error;
- (void)translateProgress:(GoogleTranslateAPI*)aGoogleTranslateAPI message:(NSString*)message;
@end

