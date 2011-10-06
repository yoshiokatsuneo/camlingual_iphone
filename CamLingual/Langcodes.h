//
//  Langcodes.h
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Langcodes : NSObject
{
    NSMutableDictionary *lang_to_threeletter;
    NSMutableDictionary *lang_to_twoletter;
}
- threeletterFromLang:(NSString*)lang;
- twoletterFromLang:(NSString*)lang;
@end
