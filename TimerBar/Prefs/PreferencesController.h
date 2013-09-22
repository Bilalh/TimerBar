//
//  TimerBarAppDelegate.m
//  TimerBar
//
//  Created by Bilal Syed Hussain on 21/09/2013.
//  Copyright (c) 2013 Bilal Syed Hussain. All rights reserved.
//

#import <ShortcutRecorder/ShortcutRecorder.h>

@interface PreferencesController : NSWindowController <SRRecorderControlDelegate>
{
    NSUserDefaultsController *defaults;
}

@property (nonatomic, retain) IBOutlet SRRecorderControl *startPauseShortcut;
@property (nonatomic, retain) IBOutlet SRRecorderControl *endShortcut;


@end
