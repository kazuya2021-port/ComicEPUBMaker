//
//  MakeProjectFolder.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/25.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "MakeProjectFolder.h"

@interface MakeProjectFolder ()

@end

@implementation MakeProjectFolder

// return YES -> make success or made NO -> error
- (BOOL)makeProject:(BOOL)isMakeFolder
{
    NSString *prjRoot = [_setting.projectPath path];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // 年 月　フォルダなければ作成
    NSString *nowDate = [KZLibs getNowDate:@"yyyy/mm"];
    NSString *year = [NSString stringWithFormat:@"%@年",[nowDate substringWithRange:NSMakeRange(0, 4)]];
    NSString *month = [NSString stringWithFormat:@"%@月",[nowDate substringWithRange:NSMakeRange(5, 2)]];
    NSString *prjName = [NSString stringWithFormat:@"%@_%@", _setting.eCode, _setting.title];
    NSString *curFold = nil;
    if ([KZLibs isExistString:prjRoot searchStr:prjName]) {
        curFold = prjRoot;
    }
    else {
        curFold = [[[prjRoot stringByAppendingPathComponent:year]
                    stringByAppendingPathComponent:month]
                   stringByAppendingPathComponent:prjName];

    }
    
    // Year/Month/ProjectRoot
    if (isMakeFolder) {
        [fm createDirectoryAtPath:curFold withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            Log(error.description);
            return NO;
        }
        
        NSMutableArray *makeFNames = [@[
                                [curFold stringByAppendingPathComponent:PRJ_1_FOLDER],
                                [curFold stringByAppendingPathComponent:PRJ_2_FOLDER],
                                [curFold stringByAppendingPathComponent:PRJ_3_FOLDER],
                                [curFold stringByAppendingPathComponent:PRJ_4_FOLDER],
                                [curFold stringByAppendingPathComponent:PRJ_5_FOLDER]
                                ] mutableCopy];
        
        curFold = makeFNames[3];
        _projectFolder = makeFNames[4];
        
        NSString *date = [KZLibs getNowDate:@"yyyymmdd"];
        NSString *curFoldNouhin = [curFold stringByAppendingPathComponent:
                                   [NSString stringWithFormat:@"%@-%@-%@", _setting.eCode, _setting.title, date]];
        NSArray *makeUpFolder = @[curFoldNouhin,
                                  [curFoldNouhin stringByAppendingPathComponent:@"EPUB"],
                                  [curFoldNouhin stringByAppendingPathComponent:@"カバー（サムネイル含む）"],
                                  [curFoldNouhin stringByAppendingPathComponent:@"背"],
                                  [curFoldNouhin stringByAppendingPathComponent:@"TIFF"]];
        
        [makeFNames addObjectsFromArray:makeUpFolder];
        
        BOOL isError = NO;
        for (NSString *f in makeFNames) {
            [fm createDirectoryAtPath:f withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                Log(error.description);
                isError = YES;
                break;
            }
        }

        if (isError) return NO;
    }
    else {
        return [fm fileExistsAtPath:curFold];
    }
    
    return YES;
}
@end
