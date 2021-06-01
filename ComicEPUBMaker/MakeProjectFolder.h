//
//  MakeProjectFolder.h
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/25.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingInfo.h"

@class SettingInfo;

@interface MakeProjectFolder : NSObject
@property (nonatomic, weak) SettingInfo *setting;
@property (nonatomic, copy) NSString *projectFolder;
- (BOOL)makeProject:(BOOL)isMakeFolder;
@end
