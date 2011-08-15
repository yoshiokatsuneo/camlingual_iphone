//
//  GoogleTranslateAPI.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GoogleTranslateAPI.h"
#import "SBJson.h"
#import "NSString+HTML.h"

@implementation GoogleTranslateAPI
@synthesize delegate = _delegate;
@synthesize connection = _connection;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [responsebody appendString:str];
    [str release]; str = nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"responsebody=[%@]", responsebody);
    NSDictionary *dic = [responsebody JSONValue];
    NSLog(@"dic=[%@]", dic);
    NSDictionary *responseData = [dic valueForKey:@"responseData"];
    NSLog(@"responseData=[%@]", responseData);
    NSString *translated_text = [responseData valueForKey:@"translatedText"];
    NSLog(@"translatedText=[%@]", translated_text);
    NSString *unencoded_text = [translated_text stringByConvertingHTMLToPlainText];
    [self.delegate translateDidFinished:self text:unencoded_text];
    
    self.connection = nil;
    [responsebody release]; responsebody = nil;
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate translate:self didFailWithError:error];
}

-(BOOL)translate:(NSString *)string delegate:(id<GoogleTranslateAPIDelegate>)delegate;
{
    NSString *lang_source = @"fi";
    NSString *lang_dest = @"en";


    NSString *encodedString = (NSString*) CFURLCreateStringByAddingPercentEscapes(NULL,  (CFStringRef)string, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);
    
    NSString *requestbody = [NSString stringWithFormat:@"v=1.0&q=%@&langpair=%@%%7C%@",encodedString,lang_source,lang_dest];
 
    NSURL *url = [NSURL URLWithString:@"http://ajax.googleapis.com/ajax/services/language/translate"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
//    [urlRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Encoding"];
    
    NSLog(@"requestbody=[%@]", requestbody);
    
    NSData *bodydata = [requestbody dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:bodydata];
    
    responsebody = [[NSMutableString alloc] init];
    self.delegate = delegate;
    self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    
    return YES;

}
@end
