//
//  XmlData.h
//  XMLTool
//
//  Created by Hens Zimmerman on 3/18/12.
//  Copyright (c) 2012 HZ37Land. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XmlData : NSObject
{
    NSMutableString* title;
    NSMutableString* product;
    NSInteger version;
    NSMutableString* advertiser;
    NSInteger length;
    NSMutableString* tcIn;
    NSMutableString* tcOut;
    NSMutableString* aspectRatio;
    NSMutableString* agency;
    NSMutableString* productionCompany;
    NSMutableString* file1;
    NSMutableString* file2;
    NSMutableString* file3;
    NSMutableString* file4;
    NSMutableString* file5;
    NSMutableString* comments;
    NSDate* date; 
    BOOL isHD;
    NSMutableString* fileName;
}

@property (readwrite, copy) NSMutableString* title;
@property (readwrite, copy) NSMutableString* product;
@property (readwrite) NSInteger version;
@property (readwrite, copy) NSMutableString* advertiser;
@property (readwrite) NSInteger length;
@property (readwrite, copy) NSMutableString* tcIn;
@property (readwrite, copy) NSMutableString* tcOut;
@property (readwrite, copy) NSMutableString* aspectRatio;
@property (readwrite, copy) NSMutableString* agency;
@property (readwrite, copy) NSMutableString* productionCompany;
@property (readwrite, copy) NSMutableString* file1;
@property (readwrite, copy) NSMutableString* file2;
@property (readwrite, copy) NSMutableString* file3;
@property (readwrite, copy) NSMutableString* file4;
@property (readwrite, copy) NSMutableString* file5;
@property (readwrite, copy) NSMutableString* comments;
@property (readwrite, copy) NSDate* date;
@property (readwrite) BOOL isHD;
@property (readwrite, copy) NSMutableString* fileName;

- (NSString*) fileNameSafe: (NSString*) s;
- (void) saveUserSettings;
- (NSString*) secondsToTimeCode: (NSInteger) seconds;
- (void) today;
- (void) updateFileName;
- (BOOL) writeXmlFile: (NSURL*) url;

@end
