//
//  MakeFolder.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/26.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "MakeFolder.h"


@interface MakeFolder ()

@end

@implementation MakeFolder

- (BOOL)copyTemplate:(NSString*)root noCopyBookWalker:(BOOL)noCopyBookWalker
{
    if (!root) {
        return NO;
    }

    NSString *resPath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"Contents/Resources"];

    NSDictionary *cpMime = @{@"AT" : [resPath stringByAppendingPathComponent:@"mimetype"],
                             @"TO" : [root stringByAppendingPathComponent:@"mimetype"]};
    
    NSDictionary *cpContainer = @{@"AT" : [resPath stringByAppendingPathComponent:@"container.xml"],
                                  @"TO" : [[root stringByAppendingPathComponent:@"META-INF"]
                                           stringByAppendingPathComponent:@"container.xml"]};
    
    root = [root stringByAppendingPathComponent:@"item"];
    NSString *styleTop = [root stringByAppendingPathComponent:@"style"];
    NSString *imageTop = [root stringByAppendingPathComponent:@"image"];
    NSArray *styles = @[
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"book-style.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"book-style.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"fixed-layout-jp.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"fixed-layout-jp.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-advance.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-advance.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-check.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-check.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-kadokawa.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-kadokawa.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-karc.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-karc.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-reset.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-reset.css"]},
                         @{@"AT" : [resPath stringByAppendingPathComponent:@"style-standard.css"],
                           @"TO" : [styleTop stringByAppendingPathComponent:@"style-standard.css"]},
                         ];
    
    NSArray *images = @[
                        @{@"AT" : [resPath stringByAppendingPathComponent:@"i-bookwalker.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-bookwalker.jpg"]}
                        /*@{@"AT" : [resPath stringByAppendingPathComponent:@"i-colophon.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-colophon.jpg"]},
                        @{@"AT" : [resPath stringByAppendingPathComponent:@"i-first-white.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-first-white.jpg"]}*/
                        ];
    
    NSArray *images105148 = @[
                           @{@"AT" : [resPath stringByAppendingPathComponent:@"i-bookwalker_105_148.jpg"],
                             @"TO" : [imageTop stringByAppendingPathComponent:@"i-bookwalker.jpg"]}
                           /*@{@"AT" : [resPath stringByAppendingPathComponent:@"i-colophon.jpg"],
                            @"TO" : [imageTop stringByAppendingPathComponent:@"i-colophon.jpg"]},
                            @{@"AT" : [resPath stringByAppendingPathComponent:@"i-first-white_127.jpg"],
                            @"TO" : [imageTop stringByAppendingPathComponent:@"i-first-white.jpg"]}*/
                           ];
    NSArray *images105149 = @[
                              @{@"AT" : [resPath stringByAppendingPathComponent:@"i-bookwalker_105_149.jpg"],
                                @"TO" : [imageTop stringByAppendingPathComponent:@"i-bookwalker.jpg"]}
                              /*@{@"AT" : [resPath stringByAppendingPathComponent:@"i-colophon.jpg"],
                               @"TO" : [imageTop stringByAppendingPathComponent:@"i-colophon.jpg"]},
                               @{@"AT" : [resPath stringByAppendingPathComponent:@"i-first-white_127.jpg"],
                               @"TO" : [imageTop stringByAppendingPathComponent:@"i-first-white.jpg"]}*/
                              ];
    NSArray *images127 = @[
                        @{@"AT" : [resPath stringByAppendingPathComponent:@"i-bookwalker_127.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-bookwalker.jpg"]}
                        /*@{@"AT" : [resPath stringByAppendingPathComponent:@"i-colophon.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-colophon.jpg"]},
                        @{@"AT" : [resPath stringByAppendingPathComponent:@"i-first-white_127.jpg"],
                          @"TO" : [imageTop stringByAppendingPathComponent:@"i-first-white.jpg"]}*/
                        ];
    
    NSArray *images148 = @[
                           @{@"AT" : [resPath stringByAppendingPathComponent:@"i-bookwalker_148.jpg"],
                             @"TO" : [imageTop stringByAppendingPathComponent:@"i-bookwalker.jpg"]}
                           /*@{@"AT" : [resPath stringByAppendingPathComponent:@"i-colophon.jpg"],
                            @"TO" : [imageTop stringByAppendingPathComponent:@"i-colophon.jpg"]},
                            @{@"AT" : [resPath stringByAppendingPathComponent:@"i-first-white_127.jpg"],
                            @"TO" : [imageTop stringByAppendingPathComponent:@"i-first-white.jpg"]}*/
                           ];
    
    NSMutableArray *arCopyInfos = [NSMutableArray array];
    [arCopyInfos addObject:cpMime];
    [arCopyInfos addObject:cpContainer];
    [arCopyInfos addObjectsFromArray:styles];
    
    if (!noCopyBookWalker) {
        if ([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH]) {
            // Default 128mm
            [arCopyInfos addObjectsFromArray:images];
        }
        else if ([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH2]) {
            [arCopyInfos addObjectsFromArray:images127];
        }
        else if ([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH3]) {
            [arCopyInfos addObjectsFromArray:images148];
        }
        else if ([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH4] && [KZLibs isEqual:_setting.hanW compare:HAN_HEIGHT4]) {
            [arCopyInfos addObjectsFromArray:images105148];
        }
        else if ([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH5] && [KZLibs isEqual:_setting.hanW compare:HAN_HEIGHT5]) {
            [arCopyInfos addObjectsFromArray:images148]; // 148x210と同じサイズ
        }
    }
    
    
    BOOL isError = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSDictionary *tbl in arCopyInfos) {
        [fm copyItemAtPath:tbl[@"AT"]
                    toPath:tbl[@"TO"]
                     error:&error];
        if (error) {
            isError = YES;
            Log(error.description);
            break;
        }
    }
    
    return isError;
}

- (void)clearFolder
{
    NSString *prjRoot = [_setting.projectPath path];
    if (!prjRoot) {
        return;
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    [fm trashItemAtURL:[NSURL fileURLWithPath:prjRoot] resultingItemURL:nil error:&error];
    if (error) {
        Log(error.description);
    }
    [fm createDirectoryAtPath:prjRoot withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        Log(error.description);
    }
}

- (BOOL)makeFolder:(BOOL)isMakeFolder
{
    NSString *prjRoot = [_setting.projectPath path];
    if (!prjRoot) {
        return NO;
    }
    
    if (!([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH] && [KZLibs isEqual:_setting.hanH compare:HAN_HEIGHT]) &&
        !([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH2] && [KZLibs isEqual:_setting.hanH compare:HAN_HEIGHT2]) &&
        !([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH3] && [KZLibs isEqual:_setting.hanH compare:HAN_HEIGHT3]) &&
        !([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH4] && [KZLibs isEqual:_setting.hanH compare:HAN_HEIGHT4]) &&
        !([KZLibs isEqual:_setting.hanW compare:HAN_WIDTH5] && [KZLibs isEqual:_setting.hanH compare:HAN_HEIGHT5])) {
        Log(@"判型エラー");
        return NO;
    }
    
    if (isMakeFolder) {
        NSUInteger filesCount = [[KZLibs getFileList:prjRoot deep:NO onlyDir:YES onlyFile:NO isAllFullPath:NO] count];
        
        __block BOOL isContinue = YES;
        if (filesCount > 0) {
            NSAlert *al = [[NSAlert alloc] init];
            al.messageText = [NSString stringWithFormat:@"[%@] にすでにフォルダがあります。\n削除して作りなおしますか？", prjRoot];
            [al addButtonWithTitle:@"続行"];
            [al addButtonWithTitle:@"キャンセル"];
            [al beginSheetModalForWindow:[KZLibs getMainWindow] completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn) {
                    isContinue = NO;
                }
            }];
            if (!isContinue) {
                return NO;
            }
            [self clearFolder];
        }
    }
    
    NSMutableArray *arMakeFolder = [@[
                                      [prjRoot stringByAppendingPathComponent:@"etc"],
                                      [prjRoot stringByAppendingPathComponent:@"material"],
                                      [prjRoot stringByAppendingPathComponent:@"release"],
                                      ] mutableCopy];
    NSString *ePubRoot = [arMakeFolder[1] stringByAppendingPathComponent:_setting.eCode];
    NSArray *ePubTop = @[
                         [ePubRoot stringByAppendingPathComponent:@"item"],
                         [ePubRoot stringByAppendingPathComponent:@"META-INF"]
                         ];
    NSString *ePubItemTop = ePubTop[0];
    NSArray *ePubItem = @[
                          [ePubItemTop stringByAppendingPathComponent:@"image"],
                          [ePubItemTop stringByAppendingPathComponent:@"style"],
                          [ePubItemTop stringByAppendingPathComponent:@"xhtml"]
                          ];
    [arMakeFolder addObject:ePubRoot];
    [arMakeFolder addObjectsFromArray:ePubTop];
    [arMakeFolder addObjectsFromArray:ePubItem];
    
    BOOL isError = NO;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    
    if (isMakeFolder) {
        for (NSString *f in arMakeFolder) {
            [fm createDirectoryAtPath:f withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                Log(error.description);
                isError = YES;
                break;
            }
        }
        
        if (isError) return NO;
        
        isError = [self copyTemplate:ePubRoot noCopyBookWalker:NO];
        
        if (isError) return NO;
    }
    else {
        return [fm fileExistsAtPath:ePubItem[0]];
    }

    return YES;
}

- (BOOL)makeTachiFolder
{
    NSString *prjRoot = [[[_setting.projectPath path] stringByAppendingPathComponent:@"material"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_t",_setting.eCode]];
    
    if (!prjRoot) {
        return NO;
    }
    
    NSFileManager* fm = NSFileManager.defaultManager;
    
    if ([fm fileExistsAtPath:prjRoot]) {
        __block BOOL isContinue = YES;
        NSAlert *al = [[NSAlert alloc] init];
        al.messageText = [NSString stringWithFormat:@"[%@] にすでにフォルダがあります。\n削除して作りなおしますか？", prjRoot];
        [al addButtonWithTitle:@"続行"];
        [al addButtonWithTitle:@"キャンセル"];
        [al beginSheetModalForWindow:[KZLibs getMainWindow] completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn) {
                isContinue = NO;
            }
        }];
        if (!isContinue) {
            return NO;
        }
        [fm trashItemAtURL:[NSURL fileURLWithPath:prjRoot] resultingItemURL:nil error:nil];
    }

    NSMutableArray *arMakeFolder = [@[prjRoot] mutableCopy];
    NSArray *ePubTop = @[
                         [prjRoot stringByAppendingPathComponent:@"item"],
                         [prjRoot stringByAppendingPathComponent:@"META-INF"]
                         ];
    NSString *ePubItemTop = ePubTop[0];
    NSArray *ePubItem = @[
                          [ePubItemTop stringByAppendingPathComponent:@"image"],
                          [ePubItemTop stringByAppendingPathComponent:@"style"],
                          [ePubItemTop stringByAppendingPathComponent:@"xhtml"]
                          ];
    [arMakeFolder addObjectsFromArray:ePubTop];
    [arMakeFolder addObjectsFromArray:ePubItem];
    
    BOOL isError = NO;
    NSError *error = nil;
    
    for (NSString *f in arMakeFolder) {
        [fm createDirectoryAtPath:f withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            Log(error.description);
            isError = YES;
            break;
        }
    }
    
    if (isError) return NO;
    
    isError = [self copyTemplate:prjRoot noCopyBookWalker:NO];
    
    if (isError) return NO;
    
    return YES;
}

- (BOOL)makeSplitFolder
{
    NSString *prjRoot = [[_setting.projectPath path] stringByAppendingPathComponent:@"material"];
    
    int splitPage = _setting.splitPage.intValue;
    unsigned long fols = _setting.theSplits.count / splitPage;
    uint mod = _setting.theSplits.count % splitPage;
    NSMutableArray *arMakeFolders = [NSMutableArray array];
    
    for (int i = 0; i < fols; i++)
    {
        [arMakeFolders addObject:[NSString stringWithFormat:@"%@-%d", _setting.eCode,i+1]];
    }
    if (mod != 0) {
        [arMakeFolders addObject:[NSString stringWithFormat:@"%@-%lu", _setting.eCode,fols+1]];
    }
    
    if (!prjRoot) {
        return NO;
    }
    
    NSFileManager* fm = NSFileManager.defaultManager;
    NSError *error = nil;
    BOOL isError = NO;
    
    for (NSString *f in arMakeFolders) {
        NSString *path = [prjRoot stringByAppendingPathComponent:f];
        if ([fm fileExistsAtPath:path]) {
            __block BOOL isContinue = YES;
            NSAlert *al = [[NSAlert alloc] init];
            al.messageText = [NSString stringWithFormat:@"[%@] にすでにフォルダがあります。\n削除して作りなおしますか？", prjRoot];
            [al addButtonWithTitle:@"続行"];
            [al addButtonWithTitle:@"キャンセル"];
            [al beginSheetModalForWindow:[KZLibs getMainWindow] completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn) {
                    isContinue = NO;
                }
            }];
            if (!isContinue) {
                return NO;
            }
            [fm trashItemAtURL:[NSURL fileURLWithPath:path] resultingItemURL:nil error:nil];
        }
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            Log(error.description);
            isError = YES;
            break;
        }
        
        NSMutableArray *arInnerFolder = [@[path] mutableCopy];
        NSArray *ePubTop = @[
                             [path stringByAppendingPathComponent:@"item"],
                             [path stringByAppendingPathComponent:@"META-INF"]
                             ];
        NSString *ePubItemTop = ePubTop[0];
        NSArray *ePubItem = @[
                              [ePubItemTop stringByAppendingPathComponent:@"image"],
                              [ePubItemTop stringByAppendingPathComponent:@"style"],
                              [ePubItemTop stringByAppendingPathComponent:@"xhtml"]
                              ];
        [arInnerFolder addObjectsFromArray:ePubTop];
        [arInnerFolder addObjectsFromArray:ePubItem];
        
        for (NSString *fo in arInnerFolder) {
            [fm createDirectoryAtPath:fo withIntermediateDirectories:YES attributes:nil error:&error];
            if (error) {
                Log(error.description);
                isError = YES;
                break;
            }
        }
        
        if (isError) {
            break;
        }
        
        isError = [self copyTemplate:path noCopyBookWalker:YES];
        
        if (isError) {
            break;
        }
    }
    
    if (isError) return NO;
    
    return YES;
}
@end
