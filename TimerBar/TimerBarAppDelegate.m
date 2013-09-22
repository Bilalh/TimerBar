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
    
    self.statusItem = [statusBar statusItemWithLength:47];
    [statusItem setTitle:@""];
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
    [timer invalidate];
    seconds = 0;
    
    [statusItem setTitle:@""];
    [statusItem setImage:icon];
    [endItem setEnabled:NO];
    
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



@end



