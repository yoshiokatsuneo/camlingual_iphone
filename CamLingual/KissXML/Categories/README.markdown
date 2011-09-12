## KissXML+HTML
Added methods for parsing HTML to [KissXML](http://code.google.com/p/kissxml/ "KissXML").

### How to Use
    #import <Foundation/Foundation.h>
    #import "DDXML+HTML.h"

    NSError *error = nil;

    // html
    NSXMLDocument *htmlDocument = [[DDXMLDocument alloc]
        initWithHTMLData:htmlData
                 options:HTML_PARSE_NOWARNING | HTML_PARSE_NOERROR
                   error:&error
    ];

    // xml
    NSXMLDocument *xmlDocument = [[DDXMLDocument alloc]
        initWithData:htmlData
             options:XML_PARSE_RECOVER 
               error:&error
    ];

    // xpath
    NSArray *array = [htmlDocument
        nodesForXPath:@"id(\"maincol\")/div[@class=\"content\"]/h2/following-sibling::node()[not(./preceding-sibling::node()/descendant-or-self::div[@class=\"posted\"])]"
                error:&error
    ];

