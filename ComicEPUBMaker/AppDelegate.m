//
//  AppDelegate.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/23.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingController.h"

@interface AppDelegate ()
@property (nonatomic, retain) IBOutlet SettingController* setting;
- (IBAction)openPreference:(id)sender;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openPreference:(id)sender
{
    [_setting showPanel];
}

@end
