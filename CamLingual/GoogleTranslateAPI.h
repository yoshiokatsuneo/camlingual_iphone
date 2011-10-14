//
//  GoogleTranslateAPI.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
Copyright (C) Yoshioka Tsuneo (yoshiokatsuneo@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#import <Foundation/Foundation.h>
@protocol GoogleTranslateAPIDelegate;

@interface GoogleTranslateAPI : NSObject
{
    NSMutableData *responsebodydata;
    NSMutableDictionary *langdic;
}
- (BOOL)translate:(NSString*)string  sourceLang:(NSString*)sourceLang destLang:(NSString*)destLang delegate:(id<GoogleTranslateAPIDelegate>)delegate;

@property(retain) NSString * API_key;
@property(retain) id<GoogleTranslateAPIDelegate> delegate;
@property(retain) NSURLConnection *connection;
@end

@protocol GoogleTranslateAPIDelegate <NSObject>

- (void)translateDidFinished:(GoogleTranslateAPI*)aGoogleTranslateAPI text:(NSString*)text;
- (void)translate:(GoogleTranslateAPI*)aGoogleTranslateAPI didFailWithError:(NSError*)error;
- (void)translateProgress:(GoogleTranslateAPI*)aGoogleTranslateAPI message:(NSString*)message;
@end

