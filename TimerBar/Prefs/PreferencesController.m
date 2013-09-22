//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController
@synthesize startPauseShortcut, endShortcut;


- (void)windowDidLoad
{
    [super windowDidLoad];
    
    defaults = [NSUserDefaultsController sharedUserDefaultsController];
    //[defaults setAppliesImmediately:YES];
    [self.startPauseShortcut
            bind:NSValueBinding
        toObject:defaults
     withKeyPath:@"values.hotkeys.startPause"
     options:nil];
    
    [self.endShortcut
            bind:NSValueBinding
        toObject:defaults
     withKeyPath:@"values.hotkeys.end"
         options:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
        selector:@selector(onWindowResignKey)
            name:NSWindowDidResignKeyNotification
          object:nil];
    
    
}



- (void)onWindowResignKey
{
    [self.window close];
}

#pragma mark SRRecorderControlDelegate

//- (BOOL)shortcutRecorder:(SRRecorderControl *)aRecorder canRecordShortcut:(NSDictionary *)aShortcut
//{
//    return !SRShortcutEqualToShortcut([self.startPauseShortcut objectValue], aShortcut) &&
//           !SRShortcutEqualToShortcut([self.endShortcut objectValue], aShortcut);
//}

@end
