//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import "TimerBarAppDelegate.h"
#import "PreferencesController.h"
#import "PTHotKey/PTHotKeyCenter.h"
#import "PTHotKey/PTKeyCodeTranslator.h"
#import "PTHotKey/PTHotKey+ShortcutRecorder.h"


static NSImage *icon;

@implementation TimerBarAppDelegate
@synthesize window, statusItem, menu;
@synthesize seconds, on;
@synthesize startStopItem, endItem;
@synthesize timerThread,timer,events;


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
    
    self.events = [NSMutableSet new];
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:(id)self];
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


- (IBAction)addNotification:(id)sender
{
    [self addEvent:@"Added Notification when? (HH:MM:SS)"];
}

- (IBAction)clearNotifications:(id)sender
{
    [events removeAllObjects];
}

- (void)addEvent: (NSString *)prompt{
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"Add"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSDatePicker* datePickerControl = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
	[datePickerControl setDatePickerElements: NSHourMinuteSecondDatePickerElementFlag];
    
    [alert setAccessoryView:datePickerControl];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {

    
        NSDate *d = [datePickerControl dateValue];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dc = [calendar
                                components:NSMinuteCalendarUnit|NSHourCalendarUnit|NSSecondCalendarUnit
                                  fromDate:d];
        NSInteger event = dc.hour * 3600 + dc.minute * 60 +  dc.second;
        if (event > 0){
            [events addObject:@(event)];
        }
        
        
    } else if (button == NSAlertAlternateReturn) {
        
    } else {
        NSAssert1(NO, @"Invalid input dialog button %zd", button);
    }
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
    if ([events containsObject:@(seconds)]){
        [self showNotificationWithTime:seconds];
    }
    
    self.seconds++;
    [self updateTime];
}

- (void)showNotificationWithTime:(NSInteger)secs
{
    NSUserNotification *userNotification = [NSUserNotification new];
    userNotification.title = [NSString stringWithFormat:@"%@", [self stringFromSeconds:secs]];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:userNotification];
    
}

- (NSString *)stringFromSeconds:(NSInteger)oseconds
{
	if (oseconds<60){
		return([NSString stringWithFormat:@"%zd seconds",oseconds]);
    }
    NSInteger minutes = oseconds / 60;
    if (minutes < 60){
        NSInteger scs = oseconds % 60;
        return([NSString stringWithFormat:@"%zd:%02zd minutes",minutes,scs]);
    }
    NSInteger hours = minutes / 60;
    minutes = hours % 60;
    NSInteger scs = minutes % 60;
    return([NSString stringWithFormat:@"%zd:%02zd:%02zd hours",hours,minutes,scs]);
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

#pragma mark  NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end



