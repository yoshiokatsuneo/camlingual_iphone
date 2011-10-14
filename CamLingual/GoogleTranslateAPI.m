//
//  GoogleTranslateAPI.m
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

#import "GoogleTranslateAPI.h"
#import "SBJson.h"
#import "NSString+HTML.h"

@implementation GoogleTranslateAPI
@synthesize API_key = _API_key;
@synthesize delegate = _delegate;
@synthesize connection = _connection;

- (id)init
{
    self = [super init];
    if(!self){return nil;}

    // Initialization code here.
    NSString *langmapfile = [[NSBundle mainBundle] pathForResource:@"GoogleTranslateAPILang" ofType:@"map"];
    NSError *error = nil;
    NSString *langmaptext = [NSString stringWithContentsOfFile:langmapfile encoding:NSUTF8StringEncoding error:&error];
    if(!langmaptext){
        NSLog(@"Failed to load [%@]", langmapfile);
    }
    
    langdic = [[NSMutableDictionary alloc] init];
    NSArray *lines = [langmaptext componentsSeparatedByString:@"\n"];
    for (NSString *line in lines){
        NSArray *words = [line componentsSeparatedByString:@" "];
        if([words count] == 2){
            [langdic setObject:[words objectAtIndex:1] forKey:[words objectAtIndex:0]];
        }
    }

    return self;
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if(bytesWritten < totalBytesWritten){
        [self.delegate translateProgress:self message:@"Sending ocr text to translate..."];
    }else{
        [self.delegate translateProgress:self message:@"Translating..."];        
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responsebodydata appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responsebody = [[NSString alloc] initWithData:responsebodydata encoding:NSUTF8StringEncoding];
    
    NSLog(@"responsebody=[%@]", responsebody);
    NSDictionary *dic = [responsebody JSONValue];
    NSLog(@"dic=[%@]", dic);
    NSDictionary *data = [dic valueForKey:@"data"];
    NSLog(@"data=[%@]", data);
    NSArray *translations = [data valueForKey:@"translations"];
    NSLog(@"translations=[%@]", translations);
    NSString *firstTranslation = nil;
    if(translations && translations.count > 0){
        firstTranslation = [translations objectAtIndex:0];
    }
    NSLog(@"firstTranslation=[%@]", firstTranslation);
    NSString *translatedText = [firstTranslation valueForKey:@"translatedText"];
    NSLog(@"translatedText=[%@]", translatedText);
    NSString *unencoded_text = [translatedText stringByConvertingHTMLToPlainText];
    [self.delegate translateDidFinished:self text:unencoded_text];
    
    self.connection = nil;
    [responsebodydata release]; responsebodydata = nil;
    [responsebody release]; responsebody = nil;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate translate:self didFailWithError:error];
}

- (NSString*)percentEncodeString:(NSString*)string
{
    return [(NSString*) CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)string, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8) autorelease];
}
-(BOOL)translate:(NSString *)string sourceLang:(NSString*)sourceLang destLang:(NSString*)destLang delegate:(id<GoogleTranslateAPIDelegate>)delegate;
{
    if(self.connection){
        [self.connection cancel];
        self.connection = nil;
    }
    NSString *apiSourceLang = [langdic objectForKey:sourceLang];
    NSString *apiDestLang = [langdic objectForKey:destLang];
    
    NSString *encodedAPI_key = [self percentEncodeString:self.API_key];
    NSString *encodedString = [self percentEncodeString:string];
    
    NSString *requestbody = [NSString stringWithFormat:@"key=%@&source=%@&target=%@&q=%@",encodedAPI_key,apiSourceLang,apiDestLang,encodedString];
 
    NSURL *url = [NSURL URLWithString:@"https://www.googleapis.com/language/translate/v2"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Encoding"];
    
    NSLog(@"requestbody=[%@]", requestbody);
    
    NSData *bodydata = [requestbody dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:bodydata];

    [urlRequest addValue:@"GET" forHTTPHeaderField:@"X-HTTP-Method-Override"];    

    responsebodydata = [[NSMutableData alloc] init];
    self.delegate = delegate;
    self.connection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
    
    return YES;

}
@end
