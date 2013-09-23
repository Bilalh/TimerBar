//
//  TimerBarAppDelegate.h
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PreferencesController;

@interface TimerBarAppDelegate : NSObject <NSApplicationDelegate>

@property (retain) IBOutlet NSWindow     *window;
@property (retain)          NSStatusItem *statusItem;
@property (retain) IBOutlet NSMenu       *menu;

@property (retain) IBOutlet NSMenuItem *startStopItem;
@property (retain) IBOutlet NSMenuItem *endItem;


@property NSInteger seconds;
@property bool      on;

@property (retain) NSThread *timerThread;
@property (retain) NSTimer *timer;

@property (retain) PreferencesController *preferencesController;

@property (retain) NSMutableSet *events;

@end
