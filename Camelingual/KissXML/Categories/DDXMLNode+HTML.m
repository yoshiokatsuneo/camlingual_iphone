#import "DDXMLNode+HTML.h"


@implementation DDXMLNode (HTML)

+ (BOOL)isXmlDocPtr:(xmlKindPtr)kindPtr
{
    return kindPtr->type == XML_DOCUMENT_NODE
        || kindPtr->type == XML_HTML_DOCUMENT_NODE;
}

@end
