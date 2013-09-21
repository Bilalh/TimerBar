//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import "TimerBarAppDelegate.h"

@implementation TimerBarAppDelegate
@synthesize window, statusItem,menu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [statusBar statusItemWithLength:24];
    [statusItem setTitle:@"T"];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    
    NSImage *icon  = [NSImage imageNamed:@"Timer"];
    [statusItem setImage:icon];

    
}

@end
