//
//  Langcodes.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Langcodes.h"


@implementation Langcodes

- (id)init
{
    self = [super init];
    if(!self){return nil;}
    
    // http://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt
    NSString *langmapfile = [[NSBundle mainBundle] pathForResource:@"ISO-639-2_utf-8" ofType:@"txt"];
    NSError * error = nil;
    NSString *langmaptext = [NSString stringWithContentsOfFile:langmapfile encoding:NSUTF8StringEncoding error:&error];
    if(!langmapfile){
        NSLog(@"Failed to load [%@]", langmapfile);
    }
    
    lang_to_twoletter = [[NSMutableDictionary alloc] init];
    lang_to_threeletter = [[NSMutableDictionary alloc] init];
    
    NSArray * lines = [langmaptext componentsSeparatedByString:@"\n"];
    for(NSString *line in lines){
        NSArray *cols = [line componentsSeparatedByString:@"|"];
        if([cols count] != 5){
            continue;
        }
        NSString *lang = [cols objectAtIndex:3];
        NSString *twoletter = [cols objectAtIndex:2];
        NSString *threeletter = [cols objectAtIndex:0];
        [lang_to_twoletter setObject:twoletter forKey:[lang uppercaseString]];
        [lang_to_threeletter setObject:threeletter forKey:[lang uppercaseString]];
    }
    
    
    return self;
}
- (void)dealloc {
    [lang_to_twoletter release];
    [lang_to_threeletter release];
    [super dealloc];
}
- threeletterFromLang:(NSString*)lang
{
    NSString *langUpper = [[[lang componentsSeparatedByString:@"_"] objectAtIndex:0] uppercaseString];
    NSString *threeletter = [[lang_to_threeletter objectForKey:langUpper] uppercaseString];
    if(threeletter == nil || [threeletter length] == 0){
        threeletter = [lang substringToIndex:3];
    }
    return threeletter;
}
- twoletterFromLang:(NSString*)lang
{
    NSString *langUpper = [[[lang componentsSeparatedByString:@"_"] objectAtIndex:0] uppercaseString];
    NSString *twoletter = [[lang_to_twoletter objectForKey:langUpper] uppercaseString];
    if(twoletter == nil || [twoletter length] == 0){
        twoletter = [lang substringToIndex:3];
    }
    return twoletter;
}
@end
