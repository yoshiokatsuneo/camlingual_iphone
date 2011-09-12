#import "DDXMLDocument+HTML.h"
#import "DDXMLPrivate.h"

enum {
    XMLDocument,
    HTMLDocument
};
typedef NSUInteger DocumentContent;

@implementation DDXMLDocument (HTML)

- (void)setError:(NSError **)error code:(NSInteger)code
{
    if (!error) {
        return;
    }

    *error = [NSError
        errorWithDomain:@"DDXMLErrorDomain"
                   code:code
               userInfo:nil
    ];
}

- (id)initWithData:(NSData *)data
           content:(DocumentContent)content
           options:(NSUInteger)options
             error:(NSError **)error
{
    if (data == nil || [data length] == 0) {
        [self setError:error code:0];
        [self release];
        return nil;
    }

    xmlKeepBlanksDefault(0);

    xmlDocPtr doc;
    if (HTMLDocument == content) {
        doc = htmlReadMemory(
            [data bytes], [data length],
            "", NULL, options
        ); 
    } else {
        doc = xmlReadMemory(
            [data bytes], [data length],
            "", NULL, options
        );
    }

    if (doc == NULL) {
        [self setError:error code:1];
        [self release];
        return nil;
    }

    return [self initWithDocPrimitive:doc freeOnDealloc:YES]; }

- (id)initWithHTMLString:(NSString *)string
                 options:(NSUInteger)options
                   error:(NSError **)error
{
    return [self
        initWithHTMLData:[string dataUsingEncoding:NSUTF8StringEncoding]
                 options:options
                   error:error
    ];
}

- (id)initWithHTMLData:(NSData *)data
               options:(NSUInteger)options
                 error:(NSError **)error
{
    return [self
        initWithData:data
             content:HTMLDocument
             options:options
               error:error
    ];
}

- (id)initWithData:(NSData *)data
           options:(NSUInteger)options
             error:(NSError **)error
{
    return [self
        initWithData:data
             content:XMLDocument
             options:options
               error:error
    ];
}

@end
