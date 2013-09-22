//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import "TimerBarAppDelegate.h"
#import "PreferencesController.h"
#import <PTHotKey/PTHotKeyCenter.h>
#import <PTHotKey/PTKeyCodeTranslator.h>
#import <PTHotKey/PTHotKey+ShortcutRecorder.h>


static NSImage *icon;

@implementation TimerBarAppDelegate
@synthesize window, statusItem, menu;
@synthesize seconds, on;
@synthesize startStopItem, endItem;
@synthesize timerThread,timer;


#pragma mark Init

+ (void) initialize{
   icon  = [NSImage imageNamed:@"Timer"];
   NSDictionary *d = [NSDictionary dictionaryWithContentsOfFile:
     [[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]];
   [[NSUserDefaults standardUserDefaults] registerDefaults:d];
     [[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:d];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [statusBar statusItemWithLength:47];
    [statusItem setTitle:@""];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    on = false;
    
    [self updateHotkeys];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(updateHotkeys:)
            name:NSUserDefaultsDidChangeNotification
          object:nil];
    
}


#pragma mark Actions

- (IBAction)startStop:(id)sender
{
    [self startStop];
}

- (void)startStop
{
    if (on){
        [timer invalidate];
        [self updateTime];
        
        [startStopItem setTitle: NSLocalizedString(@"Resume",nil)];
        [endItem setEnabled:NO];
        
    }else{
        timerThread = [[NSThread alloc]
                       initWithTarget:self
                       selector:@selector(startTimer)
                       object:nil];
        [timerThread start];
        [self updateTime];
        
        
        [statusItem setImage:Nil];
        [startStopItem setTitle: NSLocalizedString(@"Pause",nil)];
        [endItem setEnabled:YES];
    }
    
    on = !on;
}

- (IBAction)end:(id)sender
{
    [self end];
}

- (void)end
{
    [timer invalidate];
    on = false;
    seconds = 0;
    
    [statusItem setTitle:@""];
    [statusItem setImage:icon];
    [endItem setEnabled:NO];
    
    [startStopItem setTitle: NSLocalizedString(@"Start",nil)];
}


#pragma mark timer

- (void)startTimer
{
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        self.timer = [NSTimer
                      timerWithTimeInterval:1.0
                      target:self
                      selector:@selector(tick)
                      userInfo:nil
                      repeats:YES];
        [runLoop
          addTimer:self.timer
          forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (void)updateTime
{
    [statusItem setTitle:[NSString stringWithFormat:@"%02zd:%02zd", seconds / 60, seconds % 60]];
}

- (void)tick
{
    self.seconds++;
    [self updateTime];
}


#pragma mark prefs

- (IBAction)preferences:(id)sender {
    if (self.preferencesController == nil) {
        PreferencesController* pc = [[PreferencesController alloc]
                                     initWithWindowNibName:@"PreferencesController"];
        self.preferencesController = pc;
    }
    
    [self.preferencesController showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
}


- (void)updateHotkeys:(NSNotification*)notification
{
    [self updateHotkeys];
}

- (void)updateHotkeys
{
 
    void (^updateKeybinding)(NSString*,SEL,NSMenuItem*) = ^(NSString *key,SEL sel,NSMenuItem *item){
        PTHotKeyCenter *hotKeyCenter = [PTHotKeyCenter sharedCenter];
        PTHotKey *oldHotKey          = [hotKeyCenter hotKeyWithIdentifier:key];
        [hotKeyCenter unregisterHotKey:oldHotKey];
        
        NSDictionary *d = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        PTHotKey *newHotKey = [PTHotKey hotKeyWithIdentifier:key
                                                    keyCombo:d
                                                      target:self
                                                      action:sel];
        [hotKeyCenter registerHotKey:newHotKey];
        
        [item setKeyEquivalentModifierMask: [d[@"modifierFlags"] unsignedIntegerValue]];
        [item setKeyEquivalent: [[PTKeyCodeTranslator currentTranslator]
                                 translateKeyCode:[d[@"keyCode"] integerValue]] ];
        
	};
    
    updateKeybinding(@"hotkeys.startPause",@selector(startStop),startStopItem);
    updateKeybinding(@"hotkeys.end",@selector(end),endItem);

}

@end



