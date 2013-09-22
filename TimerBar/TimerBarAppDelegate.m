//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import "TimerBarAppDelegate.h"


static NSImage *icon;

@implementation TimerBarAppDelegate
@synthesize window, statusItem, menu;
@synthesize seconds, on;
@synthesize startStopItem, endItem;
@synthesize timerThread,timer;


#pragma mark Init

+ (void) initialize{
   icon  = [NSImage imageNamed:@"Timer"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window close];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [statusBar statusItemWithLength:24];
    [statusItem setTitle:@"T"];
    [statusItem setImage:icon];
    [statusItem setHighlightMode:YES];
    [statusItem setMenu:menu];
    on = false;
    
}

#pragma mark Actions

- (IBAction)startStop:(id)sender
{
    if (on){
        [timer invalidate];
        [self setTime];
        
        [startStopItem setTitle: NSLocalizedString(@"Resume",nil)];
        
    }else{
        timerThread = [[NSThread alloc]
                       initWithTarget:self
                       selector:@selector(startTimer)
                       object:nil];
        [timerThread start];
        [self setTime];
        

        [statusItem setImage:Nil];
        [startStopItem setTitle: NSLocalizedString(@"Pause",nil)];
    }
    
    on = ! on;
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

- (void)setTime
{
    
    if ([statusItem length] != 47.0){
        [statusItem setLength:47.0];
    }
    
    [statusItem setTitle:[NSString stringWithFormat:@"%02zd:%02zd", seconds / 60, seconds % 60]];
}

- (void)tick
{
    self.seconds++;
    [self setTime];
}



@end



