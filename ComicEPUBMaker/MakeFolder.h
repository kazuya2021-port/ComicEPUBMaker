//
//  MakeFolder.h
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/26.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@class SettingInfo;

@interface MakeFolder : NSObject
@property (nonatomic, weak) SettingInfo *setting;
- (BOOL)makeFolder:(BOOL)isMakeFolder;
- (BOOL)makeTachiFolder;
- (BOOL)makeSplitFolder;
@end
