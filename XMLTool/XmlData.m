//
//  XmlData.m
//  XMLTool
//
//  Created by Hens Zimmerman on 3/18/12.
//  Copyright (c) 2012 HZ37Land. All rights reserved.
//

#import "XmlData.h"

@implementation XmlData

@synthesize title;
@synthesize product;
@synthesize version;
@synthesize advertiser;
@synthesize length;
@synthesize tcIn;
@synthesize tcOut;
@synthesize aspectRatio;
@synthesize agency;
@synthesize productionCompany;
@synthesize file1;
@synthesize file2;
@synthesize file3;
@synthesize file4;
@synthesize file5;
@synthesize comments;
@synthesize date;
@synthesize emailConfirmation;
@synthesize isHD;
@synthesize isMultiChannel;
@synthesize isLowLoudnessLevel;
@synthesize fileName;

// Keys for user settings.

NSString* const HZ37_Agency = @"Agency";
NSString* const HZ37_ProductionCompany = @"Production company";
NSString* const HZ37_EmailConfirmation = @"Email confirmation";

// This is the PAL version.

NSInteger const HZ37_frameRate = 25; // fps


// Turn s into something that's safe for the filenme.
// Just a requirement of the commercial xml.

- (NSString*) fileNameSafe: (NSString*) s
{
    if (s == nil) 
    {
        return nil;
    }
    
    NSMutableString* container = [[NSMutableString alloc] initWithString:s];
    
    [container replaceOccurrencesOfString:@"\\s{1}" withString:@"-" options:NSRegularExpressionSearch range:NSMakeRange(0, [container length])];
    
    return [container lowercaseString];
}

- (id) init
{
    self = [super init];
    
    // Register user defaults.
    
    NSMutableDictionary* defaultValues = [NSMutableDictionary dictionary];
    
    [defaultValues setObject:@"" forKey:HZ37_Agency];
    [defaultValues setObject:@"" forKey:HZ37_ProductionCompany];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    
    // Restore user preferences.
    
    NSUserDefaults* userDefaults  = [NSUserDefaults standardUserDefaults];

    [self setValue:[userDefaults stringForKey:HZ37_Agency] forKey:@"agency"];
    [self setValue:[userDefaults stringForKey:HZ37_ProductionCompany] forKey:@"productionCompany"];
    [self setValue:[userDefaults stringForKey:HZ37_EmailConfirmation] forKey:@"emailConfirmation"];
    
    [self setValue:@"" forKey:@"title"];
    [self setValue:@"" forKey:@"product"];
    [self setValue:[[NSNumber alloc] initWithInteger:1] forKey:@"version"];
    [self setValue:[[NSNumber alloc] initWithInteger:5] forKey:@"length"];
    [self setValue:@"00:00:00:00" forKey:@"tcIn"];
    [self setValue:@"00:00:04:24" forKey:@"tcOut"];
    [self setValue:@"16F16" forKey:@"aspectRatio"];
    [self today];
    
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"product" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"version" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"length" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"date" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isHD" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isMultiChannel" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"isLowLoudnessLevel" options:NSKeyValueObservingOptionNew context:nil];

    [self updateFileName];

    return self;
}


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"length"]) 
    {
        [self setValue:[self secondsToTimeCode:length] forKey:@"tcOut"];
    }
        
    // And for all observed changes we have to update the filename.
    
    [self updateFileName];
}


// Save user preferences/settings to disk.

- (void) saveUserSettings
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setValue:agency forKey:HZ37_Agency];
    [userDefaults setValue:productionCompany forKey:HZ37_ProductionCompany];
    [userDefaults setValue:emailConfirmation forKey:HZ37_EmailConfirmation];
}


- (NSString*) secondsToTimeCode: (NSInteger) seconds
{
    NSInteger frames = (seconds * HZ37_frameRate) - 1;
    NSInteger h = frames / (3600 * HZ37_frameRate);
    frames -= (h * 3600 * HZ37_frameRate);
    NSInteger m = frames / (60 * HZ37_frameRate);
    frames -= (m * 60 * HZ37_frameRate);
    NSInteger s = frames / HZ37_frameRate;

    return [[NSString alloc] initWithFormat:@"%.02ld:%.02ld:%.02ld:%.02ld", h, m, s, frames % HZ37_frameRate];
}


- (void) today
{
    NSDate* now = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    [self setValue:now forKey:@"date"];
}


- (void) updateFileName
{
    // Title AB, Product CD:
    // cd_ab_5_versie-1_18-02-2010_HD
    // cd_ab_15_versie-1_18-02-2010
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    
    NSInteger day = [components day];
    NSInteger month = [components month];
    NSInteger year = [components year];
    
    NSString* newFileName = [[NSString alloc] initWithFormat:@"%@_%@_%ld_versie-%ld_%.02ld-%.02ld-%.04ld%@", [self fileNameSafe:product], [self fileNameSafe:title], length, version, day, month, year, (isHD ? @"_HD" : @"")];
    [self setValue:newFileName forKey:@"fileName"];
    
    // If we have enough information, post to notification center. If not, we post a message that we don't.
    // This will allow the create xml button to be en- or disabled.
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    if ([product length] > 0 && [title length] > 0) 
    {
        [nc postNotificationName:@"Turn it on" object:self];
    }
    else
    {
        [nc postNotificationName:@"Turn it off" object:self];
    }
}


- (BOOL) writeXmlFile: (NSURL*) url
{
    // Create XML document.
    
    NSXMLElement* root = [[NSXMLElement alloc] initWithName:@"COMMERCIAL_DETAILS"];
    NSXMLDocument* xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    [xmlDoc setStandalone:YES];

    // Add all the child elements.
    
    NSXMLElement* element;
    NSNumber* n;
    
    element = [[NSXMLElement alloc] initWithName:@"TITLE" stringValue:[self valueForKey:@"title"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"PRODUCT" stringValue:[self valueForKey:@"product"]];
    [root addChild:element];

    n = [self valueForKey:@"version"];
    element = [[NSXMLElement alloc] initWithName:@"VERSION" stringValue:[n stringValue]];
    [root addChild:element];

    element = [[NSXMLElement alloc] initWithName:@"ADVERTISER" stringValue:[self valueForKey:@"advertiser"]];
    [root addChild:element];
    
    n = [self valueForKey:@"length"];
    element = [[NSXMLElement alloc] initWithName:@"LENGTH" stringValue:[n stringValue]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"TC_IN" stringValue:[self valueForKey:@"tcIn"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"TC_OUT" stringValue:[self valueForKey:@"tcOut"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"ASPECT_RATIO" stringValue:[self valueForKey:@"aspectRatio"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"AGENCY" stringValue:[self valueForKey:@"agency"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"PRODUCTION_COMPANY" stringValue:[self valueForKey:@"productionCompany"]];
    [root addChild:element];
    
    for (NSInteger idx = 1; idx < 6; ++idx) 
    {
        NSString* fieldName = [[NSString alloc] initWithFormat:@"ADDITIONAL_FILE_00%ld", idx];
        NSString* key = [[NSString alloc] initWithFormat:@"file%ld", idx];
        element = [[NSXMLElement alloc] initWithName:fieldName stringValue:[self valueForKey:key]];
        [root addChild:element];
    }
    
    element = [[NSXMLElement alloc] initWithName:@"COMMENTS" stringValue:[self valueForKey:@"comments"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"EMAIL_CONFIRMATION" stringValue:[self valueForKey:@"emailConfirmation"]];
    [root addChild:element];
    
    element = [[NSXMLElement alloc] initWithName:@"HD" stringValue:isHD ? @"TRUE" : @"FALSE"];
    [root addChild:element];
         
    element = [[NSXMLElement alloc] initWithName:@"MULTI_CHANNEL_AUDIO" stringValue:isMultiChannel ? @"TRUE" : @"FALSE"];
    [root addChild:element];

    element = [[NSXMLElement alloc] initWithName:@"LOW_LOUDNESS_LEVEL" stringValue:isLowLoudnessLevel ? @"TRUE" : @"FALSE"];
    [root addChild:element];

    // Write it to disk.
    
    NSData* xml = [xmlDoc XMLDataWithOptions:NSXMLNodePrettyPrint];
    
    return [xml writeToURL:url atomically:YES];
}


@end
