//
//  MakeEPUB.h
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/26.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@class SettingInfo;

#define RES_PATH [[NSBundle.mainBundle bundlePath] stringByAppendingPathComponent:@"Contents/Resources"]
#define RETCODE @"\r\n"

@interface MakeEPUB : NSObject

@property (nonatomic, weak) SettingInfo *setting;
- (BOOL)makeEPUB;
- (BOOL)makeTachiEPUB;
- (BOOL)makeSplitEPUB;
@end
