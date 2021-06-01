//
//  SettingController.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/25.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "SettingController.h"

@interface SettingController ()
@property (nonatomic, strong) IBOutlet NSPanel *window;
@property (nonatomic, strong) IBOutlet NSTextField *txtPath;
@property (nonatomic, copy) NSString *defaultFolder;
- (IBAction)saveSetting:(id)sender;
- (IBAction)openFolder:(id)sender;
@end

@implementation SettingController

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _defaultFolder = ([ud stringForKey:@"PROJECT_PATH"])? [ud stringForKey:@"PROJECT_PATH"]:NSHomeDirectory();
    _txtPath.stringValue = _defaultFolder;
}

- (void)showPanel
{
    [_window makeKeyAndOrderFront:self];
}

- (IBAction)openFolder:(id)sender
{
    NSArray *paths = [KZLibs openFileDialog:@"Open Root Folder" multiple:NO selectFile:NO selectDir:YES];
    if (paths.count == 0) return;
    
    _txtPath.stringValue = paths[0];
}

- (IBAction)saveSetting:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:_txtPath.stringValue forKey:@"PROJECT_PATH"];
    [ud synchronize];
}
@end
