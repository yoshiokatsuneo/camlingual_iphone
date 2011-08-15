//
//  OCRWebService.h
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OCRWebServiceDelegate;

@interface OCRWebService : NSObject
{
    NSMutableString *responsebody;
}

// - (int)OCRWebServiceAvailablePages;
- (BOOL)OCRWebServiceRecognize: (NSString*)imagefile ocrLanguage:(NSString*)ocrLanguage outputDocumentFormat:(NSString*)outputDocumentFormat delegate:(id<OCRWebServiceDelegate>)delegate;

@property (retain) NSString *user_name;
@property (retain) NSString *license_code;
@property (retain) NSURLConnection *connection;

@property (retain) id<OCRWebServiceDelegate> delegate;
@end

@protocol OCRWebServiceDelegate <NSObject>

-(void)OCRWebService:(OCRWebService*)aOCRWebService didFailWithError:(NSError*)error;
-(void)OCRWebServiceDidFinish:(OCRWebService *)aOCRWebService ocrText:(NSString*)ocrText;;
-(void)OCRWebServiceProgress:(OCRWebService*)aOCRWebServer message:(NSString*)message progress:(float)progress;

@end




