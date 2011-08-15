//
//  OCRWebService.m
//  Camelingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OCRWebService.h"
#import "DDXML.h"
#import "NSData+Base64.h"

@implementation OCRWebService
@synthesize user_name;
@synthesize license_code;
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
-(void)dealloc
{
    [user_name release];
    [license_code release];
    self.delegate = nil;
    [_connection release];
    [super dealloc];
}
- (void)showxmltree:(DDXMLElement *)element
{
    NSLog(@"Element: %@", [element stringValue]);
    for (DDXMLElement *child in [element children]){
        [self showxmltree:child];
    }
}
- (void)errorAlert:(NSError*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[[error userInfo] description] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}





-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate OCRWebService:self didFailWithError:error];
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse*) response;
    int status_code = [httpresponse statusCode];
    
    if(status_code != 200){
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid HTTP status code(%d) for URL:%@", status_code,[response URL]] forKey:NSLocalizedDescriptionKey]];
        [self.delegate OCRWebService:self didFailWithError:error];
    }
    
    [self.delegate OCRWebServiceProgress:self message:@"didReceiveResponse" progress:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
//    NSString *responsebody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"responsebody=[%@]", responsebody);
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [responsebody appendString:str];
    [str release]; str = nil;
    [self.delegate OCRWebServiceProgress:self message:[NSString stringWithFormat:@"[%d] bytes received.",[responsebody length]] progress:1.0f];
    
}
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSString *message = [NSString stringWithFormat:@"didSendBodyData:(bytesWritten)%d:(totalBytesWritten)%d:(totalBytesExpectedToWrite)%d",bytesWritten,totalBytesWritten,totalBytesExpectedToWrite];
    [self.delegate OCRWebServiceProgress:self message:message progress:((float)totalBytesWritten/(float)totalBytesExpectedToWrite)];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error = nil;
    DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithXMLString:responsebody options:0 error:&error];
    if(!xmlDocument){
        [self.delegate OCRWebService:self didFailWithError:error];
    }
    
    DDXMLElement * root = [xmlDocument  rootElement];
    [root addNamespace:[DDXMLNode namespaceWithName:@"myns" stringValue:@"http://stockservice.contoso.com/wse/samples/2005/10"]];
    [self showxmltree:root];
    
    NSArray * array = [root nodesForXPath:@"//myns:OCRWSResponse/myns:ocrText/myns:ArrayOfString/myns:string" error:&error];
    if(!array){
        [self.delegate OCRWebService:self didFailWithError:error];
        return;
    }
    DDXMLElement *element = [array lastObject];
    NSString *ocrText = [element stringValue];
    [self.delegate OCRWebServiceDidFinish:self ocrText:ocrText];
    
    
    self.connection = nil;
    [responsebody release]; responsebody = nil;
}

- (BOOL)sendRequest:(NSString*)soapAction templatename:(NSString*)templatename subst:(NSDictionary*)subst error:(NSError**)error
{
    NSString *templatefile = [[NSBundle mainBundle] pathForResource:templatename ofType:@"xml"];
    NSString *template = [NSString stringWithContentsOfFile:templatefile encoding:NSUTF8StringEncoding error:error];
    if(!template){
        return NO;
    }

    NSMutableString *requestbody = template.mutableCopy;
    for(NSString *key in subst){
        NSString *key2 = [NSString stringWithFormat:@"${%@}",key];
        [requestbody replaceOccurrencesOfString:key2 withString:[subst valueForKey:key] options:0 range:NSMakeRange(0, requestbody.length)];
        
    }
    // NSLog(@"requestbody=[%@]", requestbody);
    
    NSURL *url = [NSURL URLWithString:@"http://www.ocrwebservice.com/services/OCRWebService.asmx"];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[NSString stringWithFormat:@"\"http://stockservice.contoso.com/wse/samples/2005/10/%@\"",soapAction] forHTTPHeaderField:@"SOAPAction"];
    NSData *bodydata = [requestbody dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:bodydata];

    responsebody = [[NSMutableString alloc] init];
    self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

    return YES;
}
#if 0
- (int)OCRWebServiceAvailablePages
{
    NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:user_name,@"user_name",license_code,@"license_code", nil];
    NSError *error = nil;
    DDXMLDocument *xmlDocument = [self sendRequest:@"OCRWebServiceAvailablePages" templatename:@"OCRWebServiceAvailablePages-request-template" subst:subst error:&error];
    if(!xmlDocument){
        [self errorAlert:error];
        return -1;
    }

    DDXMLElement * root = [xmlDocument  rootElement];
    [root addNamespace:[DDXMLNode namespaceWithName:@"myns" stringValue:@"http://stockservice.contoso.com/wse/samples/2005/10"]];
    [self showxmltree:root];
    
    NSArray * array = [root nodesForXPath:@"//myns:OCRWebServiceAvailablePagesResult" error:&error];
    if(!array){
        [self errorAlert:error];
        return -1;        
    }
    DDXMLElement *element = [array lastObject];
    NSString *pagesstr = [element stringValue];
    int pages = [pagesstr intValue];
    return pages;
    
}
#endif
- (BOOL)OCRWebServiceRecognize:(NSString *)imagefile ocrLanguage:(NSString *)ocrLanguage outputDocumentFormat:(NSString *)outputDocumentFormat delegate:(id<OCRWebServiceDelegate>)delegate
{
    NSError *error = nil;
    NSData *imagedata = [NSData dataWithContentsOfFile:imagefile options:0 error:&error];
    if(!imagedata){
        [self errorAlert:error];
        return NO;
    }
    NSString *imagedatastr = [imagedata base64EncodedString];
    
    
    NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:user_name,@"user_name",license_code,@"license_code", imagefile, @"imagefilename", imagedatastr, @"imagedata", ocrLanguage, @"language", nil];
    
    self.delegate = delegate;
    [self sendRequest:@"OCRWebServiceRecognize" templatename:@"OCRWebServiceRecognize-request-template" subst:subst error:&error];
    return YES;
}
@end

