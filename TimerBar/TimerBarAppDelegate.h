//
//  TimerBarAppDelegate.h
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TimerBarAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSStatusItem *statusItem;
@property (retain) IBOutlet NSMenu *menu;

@end
