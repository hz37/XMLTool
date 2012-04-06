//
//  AppDelegate.h
//  XMLTool
//
//  Created by Hens Zimmerman on 3/17/12.
//  Copyright (c) 2012 HZ37Land. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XmlData;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    XmlData* xmlData;
}

@property (weak) IBOutlet NSButton *createXmlButton;
@property (weak) IBOutlet NSButton *c0pyButton;

- (IBAction)addFile:(id)sender;
- (IBAction)copyFileName:(id)sender;
- (IBAction)createXml:(id)sender;
- (IBAction)today:(id)sender;

@end
