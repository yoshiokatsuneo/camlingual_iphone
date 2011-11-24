//
//  LanguageSelectController.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 9/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LanguageSelectController.h"

@implementation LanguageSelectController
@synthesize sourceLangTableView;
@synthesize destLangTableView;
@synthesize delegate;
@synthesize sourceLangArray;
@synthesize destLangArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        sourceLangArray = [[NSArray alloc] initWithObjects:@"AFRIKAANS", @"BULGARIAN", @"CATALAN", @"CROATIAN", @"CZECH", @"DANISH", @"DUTCH", @"ENGLISH", @"ESTONIAN", @"FILIPINO", @"FINNISH", @"FRENCH", @"GERMAN", @"GREEK", @"HUNGARIAN", @"INDONESIAN", @"ITALIAN", @"LATVIAN", @"LITHUANIAN", @"MALAY", @"NORWEGIAN", @"POLISH", @"PORTUGUESE", @"ROMANIAN", @"RUSSIAN", @"SERBIAN", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWEDISH", @"TURKISH", @"UKRAINIAN", nil];
        destLangArray = [[NSArray alloc] initWithObjects:@"AFRIKAANS", @"ALBANIAN", @"ARABIC", @"BELARUSIAN", @"BULGARIAN", @"CATALAN", @"CHINESE_SIMPLIFIED", @"CHINESE_TRADITIONAL", @"CROATIAN", @"CZECH", @"DANISH", @"DUTCH", @"ENGLISH", @"ESTONIAN", @"FILIPINO", @"FINNISH", @"FRENCH", @"GALICIAN", @"GERMAN", @"GREEK", @"HEBREW", @"HINDI", @"HUNGARIAN", @"ICELANDIC", @"INDONESIAN", @"IRISH", @"ITALIAN", @"JAPANESE", @"KOREAN", @"LATVIAN", @"LITHUANIAN", @"MACEDONIAN", @"MALAY", @"MALTESE", @"NORWEGIAN", @"PERSIAN", @"POLISH", @"PORTUGUESE", @"ROMANIAN", @"RUSSIAN", @"SERBIAN", @"SLOVAK", @"SLOVENIAN", @"SPANISH", @"SWAHILI", @"SWEDISH", @"THAI", @"TURKISH", @"UKRAINIAN", @"VIETNAMESE", @"WELSH", @"YIDDISH", nil];

    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setSourceLangTableView:nil];
    [self setDestLangTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
    // Return YES for supported orientations
    // return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [sourceLangTableView release];
    [destLangTableView release];
    [sourceLangArray release];
    [destLangArray release];
    [super dealloc];
}



-(NSArray*)tableViewToArray:(UITableView*)tableView
{
    if(tableView == sourceLangTableView){
        return sourceLangArray;
    }else if(tableView == destLangTableView){
        return destLangArray;
    }
    return nil;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = [indexPath indexAtPosition:1];
    NSArray * array = [self tableViewToArray:tableView];
    NSString *lang = [array objectAtIndex:index];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lang];
    if(cell == nil){
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lang] autorelease];
        cell.textLabel.text = [[lang substringToIndex:1] stringByAppendingString:[[lang substringFromIndex:1] lowercaseString]];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *sourceIndexPath = [sourceLangTableView indexPathForSelectedRow];
    int sourceIndex = [sourceIndexPath indexAtPosition:1];
    NSString *sourceLang = [sourceLangArray objectAtIndex:sourceIndex];
    
    NSIndexPath *destIndexPath = [destLangTableView indexPathForSelectedRow];
    
    int destIndex = [destIndexPath indexAtPosition:1];
    NSString *destLang = [destLangArray objectAtIndex:destIndex];
    
    [delegate didChangeLanguage:self sourceLang:sourceLang destLang:destLang];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int count = 0;
    if(tableView == sourceLangTableView){
        count =  [sourceLangArray count];
    }else if(tableView == destLangTableView){
        count =  [destLangArray count];
    }
    return count;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == sourceLangTableView){
        return @"From";
    }else if(tableView == destLangTableView){
        return @"To";
    }
    return nil;
}
- (void)setLanguageSource:(NSString*)sourceLang dest:(NSString*)destLang
{
    if(sourceLang && ![sourceLangTableView indexPathForSelectedRow]){
        int index = [sourceLangArray indexOfObject:sourceLang];
        NSUInteger indexes[] = {0, index};
        NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:indexes length:2];
        [sourceLangTableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    if(destLang && ![destLangTableView indexPathForSelectedRow]){
        int index = [destLangArray indexOfObject:destLang];
        NSUInteger indexes[] = {0, index};
        NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:indexes length:2];
        [destLangTableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

@end
