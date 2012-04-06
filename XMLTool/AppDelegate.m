//
//  AppDelegate.m
//  XMLTool
//
//  Created by Hens Zimmerman on 3/17/12.
//  Copyright (c) 2012 HZ37Land. All rights reserved.
//

#import "AppDelegate.h"
#import "XmlData.h"

@implementation AppDelegate
@synthesize createXmlButton;
@synthesize c0pyButton;




- 	(void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
}

- (void)buttonState:(NSNotification *)note
{
    BOOL enabled = [note.name isEqualToString:@"Turn it on"];
        
    [createXmlButton setEnabled:enabled];
    [c0pyButton setEnabled:enabled];
}

// Just before closing, we save the user settings to disk.

- (void) applicationWillTerminate:(NSNotification *)notification
{
    // Save user settings to disk.
    
    [xmlData saveUserSettings];
}


// User wants to copy the filename to the pasteboard.

- (IBAction)copyFileName:(id)sender 
{
    NSPasteboard* pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard clearContents];
    [pasteBoard writeObjects:[NSArray arrayWithObject:xmlData.fileName]];
}


// App delegate gets deallocated. Time to unregister our notification
// according to Hillegass.

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (id) init
{
    if (self = [super init]) 
    {
        xmlData = [[XmlData alloc] init];
    }
    
    // Observe notifications from XmlData about turning buttons on or off.
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(buttonState:)
               name:@"Turn it on" object:nil];
    [nc addObserver:self selector:@selector(buttonState:)
               name:@"Turn it off" object:nil];
    
    return self;
}


- (IBAction)createXml:(id)sender 
{
    NSSavePanel* savePanel = [NSSavePanel savePanel];
	
	[savePanel setTitle:@"Save as *.xml file"];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xml", nil]];
    [savePanel setNameFieldStringValue:xmlData.fileName];
    [savePanel setNameFieldLabel:@"!!"];
    
    if ([savePanel runModal] == NSOKButton) 
    {
        [xmlData writeXmlFile:[savePanel URL]];
    }

}



- (IBAction)addFile:(id)sender 
{
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    
    if ([openPanel runModal] == NSOKButton) 
    {
        NSString* fieldName = [[NSString alloc] initWithFormat:@"file%ld", [sender tag]];
        
        [xmlData setValue:[[openPanel URL] lastPathComponent] forKey:fieldName];
    }
    
}

- (IBAction)today:(id)sender 
{
    [xmlData today];
}


@end
