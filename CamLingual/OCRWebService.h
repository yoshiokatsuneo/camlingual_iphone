//
//  OCRWebService.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
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

@protocol OCRWebServiceDelegate;

@interface OCRWebService : NSObject
{
    NSMutableData *responsebodydata;
}

// - (int)OCRWebServiceAvailablePages;
- (BOOL)OCRWebServiceRecognize: (NSString*)imagefile ocrLanguage:(NSString*)ocrLanguage outputDocumentFormat:(NSString*)outputDocumentFormat delegate:(id<OCRWebServiceDelegate>)delegate;

@property (retain) NSString *user_name;
@property (retain) NSString *license_code;
@property (retain) NSURLConnection *connection;

@property (retain) id<OCRWebServiceDelegate> delegate;
@property (retain) NSError *error;
@end

@protocol OCRWebServiceDelegate <NSObject>

-(void)OCRWebService:(OCRWebService*)aOCRWebService didFailWithError:(NSError*)error;
-(void)OCRWebServiceDidFinish:(OCRWebService *)aOCRWebService ocrText:(NSString*)ocrText;;
-(void)OCRWebServiceProgress:(OCRWebService*)aOCRWebServer message:(NSString*)message progress:(float)progress;

@end




