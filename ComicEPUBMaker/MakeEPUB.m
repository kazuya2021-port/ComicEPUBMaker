//
//  MakeEPUB.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/26.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "MakeEPUB.h"

@interface MakeEPUB ()

@end

@implementation MakeEPUB

#pragma mark -
#pragma mark Local Funcs

// 画像ファイル名(i-xxx)からxhtmlのファイル名(p-xxx.xhtml)に変換
- (NSString*)imageNameToXhtmlName:(NSString*)gfname
{
    NSString* tmp = [gfname substringFromIndex:1];
    return [NSString stringWithFormat:@"p%@.xhtml",tmp];
}


- (BOOL)isSakuin:(NSNumber*)page
{
    BOOL retVal = NO;
    if ((_setting.theDaiwari.count / 2) > [page unsignedIntegerValue]) {
        retVal = NO;
    }
    else {
        retVal = YES;
    }
    return retVal;
}

- (NSMutableArray*)getTachiRange
{
    NSMutableArray *theDai = [NSMutableArray array];
    
    NSArray *tachi;
    tachi = [_setting.tachiRange componentsSeparatedByString:@"-"];
    
    for (int i = 0; i < _setting.theDaiwari.count; i++) {
        if ((i + 1) >= [tachi[0] intValue] &&
            (i + 1) <= [tachi[1] intValue]) {
            [theDai addObject:_setting.theDaiwari[i]];
        }
    }
    [theDai addObject:_setting.theDaiwari[_setting.theDaiwari.count - 1]];
    return theDai;
}

- (NSMutableArray*)getSplitRange:(int)folIdx cpIdx:(int)cpIdx
{
    NSMutableArray *theDai = [NSMutableArray array];
    
    int splitPage = _setting.splitPage.intValue;
    unsigned long fols = _setting.theSplits.count / splitPage;
    uint mod = _setting.theSplits.count % splitPage;
    
    int startIdx = cpIdx;
    int endIdx = 0;
    if (folIdx == fols) {
        endIdx = startIdx + mod;
    }
    else {
        endIdx = startIdx + splitPage - 1;
    }
    
    for (int i = 0; i < _setting.theSplits.count; i++) {
        if (startIdx <= i && i <= endIdx) {
            [theDai addObject:_setting.theSplits[i]];
        }
    }
    
    return theDai;
}

- (NSString*)makeStandardOPF:(NSMutableArray*)theDai
{
    NSError *error = nil;
    NSMutableString *retOpf = [NSMutableString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"opf_initial"]
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
    
    [retOpf appendFormat:@"<dc:title id=\"title\">%@</dc:title>%@", _setting.title, RETCODE];
    [retOpf appendFormat:@"<meta refines=\"#title\" property=\"file-as\">%@</meta>%@%@", _setting.titlePron, RETCODE, RETCODE];
    [retOpf appendFormat:@"<!-- 著者名 -->%@", RETCODE];
    
    NSArray *arAuthors = [_setting.author componentsSeparatedByString:@","];
    NSArray *arAuthorProns = [_setting.authorPron componentsSeparatedByString:@","];
    for (int i = 0; i < arAuthors.count; i++) {
        NSString *author = arAuthors[i];
        NSString *authorP = arAuthorProns[i];
        NSString *authNum = [KZLibs paddNumber:2 num:(i + 1)];
        
        [retOpf appendFormat:@"<dc:creator id=\"creator%@\">%@</dc:creator>%@", authNum, author, RETCODE];
        [retOpf appendFormat:@"<meta refines=\"#creator%@\" property=\"role\" scheme=\"marc:relators\">aut</meta>%@", authNum, RETCODE];
        [retOpf appendFormat:@"<meta refines=\"#creator%@\" property=\"file-as\">%@</meta>%@", authNum, authorP, RETCODE];
        [retOpf appendFormat:@"<meta refines=\"#creator%@\" property=\"display-seq\">%@</meta>%@%@",
         authNum, [NSString stringWithFormat:@"%d", (i + 1)], RETCODE, RETCODE];
    }
    
    NSString* tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"opf_mid1"] encoding:NSUTF8StringEncoding error:&error];
    
    [retOpf appendString:tmp];
    [retOpf appendFormat:@"%@</dc:identifier>%@%@", _setting.eCode, RETCODE, RETCODE];
    [retOpf appendFormat:@"<!-- 更新日 -->%@", RETCODE];

    // デジタル出版日変換
    NSString* nen = [_setting.publishDate substringToIndex:4];
    NSString* gat = [_setting.publishDate substringWithRange:NSMakeRange(4, 2)];
    NSString* day = [_setting.publishDate substringFromIndex:6];
    
    [retOpf appendFormat:@"<meta property=\"dcterms:modified\">%@-%@-%@T00:00:00Z</meta>%@%@", nen, gat, day, RETCODE, RETCODE];
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"opf_mid2"] encoding:NSUTF8StringEncoding error:&error];
    
    [retOpf appendFormat:@"%@%@", tmp, RETCODE];
    
    // 画像の幅と高さ設定
    [retOpf appendFormat:@"<meta name=\"original-resolution\" content=\"%@x%@\"/>%@", _setting.orgWidth, _setting.orgHeight, RETCODE];
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"opf_mid3"] encoding:NSUTF8StringEncoding error:&error];
    
    [retOpf appendFormat:@"%@%@", tmp, RETCODE];
    [retOpf appendFormat:@"<meta property=\"fixed-layout-jp:viewport\">width=%@, height=%@</meta>%@%@", _setting.orgWidth, _setting.orgHeight, RETCODE, RETCODE];
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"opf_mid4"] encoding:NSUTF8StringEncoding error:&error];
    [retOpf appendFormat:@"%@%@", tmp, RETCODE];
    
    // 画像データ(最初はカバーなので固定)
    [retOpf appendFormat:@"<item media-type=\"image/jpeg\" id=\"cover\" href=\"image/cover.jpg\" properties=\"cover-image\"/>%@", RETCODE];
    
    // 各セクションのデータ作成
    // <!-- image --> = img_ret
    // <!-- xhtml --> = app_ret
    // <itemref       = itemref
    NSMutableString* img_ret = [[NSMutableString alloc] init];
    NSMutableString* app_ret = [[NSMutableString alloc] init];
    NSMutableString* itemref = [[NSMutableString alloc] init];
    BOOL isCoverContain = NO;
    for (int i = 0; i < theDai.count; i++) {
        NSString* fileName = theDai[i][@"dai_filename"];
        
        if (EQ_STR(fileName, @"cover"))
        {
            //カバーは設定済み
            isCoverContain = YES;
            continue;
        }
        BOOL isEven = (i%2 == 0)? NO : YES;
        
        NSString* pName = [self imageNameToXhtmlName:fileName];
        NSString* tmp = [fileName stringByAppendingString:@".jpg"];
        
        [img_ret appendFormat:@"<item media-type=\"image/jpeg\" id=\"%@\" href=\"image/%@\"/>%@", fileName, tmp, RETCODE];
        tmp = [pName substringToIndex:[pName length] - 6];
        [app_ret appendFormat:@"<item media-type=\"application/xhtml+xml\" id=\"%@\" href=\"xhtml/%@\" properties=\"svg\" fallback=\"%@\"/>%@", tmp, pName, fileName, RETCODE];

        if (isCoverContain) {
            if (_setting.isLeftOpen) {
                if (isEven) {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-left\"/>%@", tmp, RETCODE];
                }
                else {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-right\"/>%@", tmp, RETCODE];
                }
            }
            else {
                if (isEven) {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-right\"/>%@", tmp, RETCODE];
                }
                else {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-left\"/>%@", tmp, RETCODE];
                }
            }
        }
        else {
            if (_setting.isLeftOpen) {
                if (isEven) {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-right\"/>%@", tmp, RETCODE];
                }
                else {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-left\"/>%@", tmp, RETCODE];
                }
            }
            else {
                if (isEven) {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-left\"/>%@", tmp, RETCODE];
                }
                else {
                    [itemref appendFormat:@"<itemref linear=\"yes\" idref=\"%@\" properties=\"page-spread-right\"/>%@", tmp, RETCODE];
                }
            }
        }
        
    }
    
    [retOpf appendFormat:@"%@%@", img_ret, RETCODE];
    
    [retOpf appendFormat:@"<!-- xhtml -->%@", RETCODE];
    [retOpf appendFormat:@"<item media-type=\"application/xhtml+xml\" id=\"p-cover\" href=\"xhtml/p-cover.xhtml\" properties=\"svg\" fallback=\"cover\"/>%@", RETCODE];
    [retOpf appendFormat:@"%@%@", app_ret, RETCODE];
    [retOpf appendFormat:@"</manifest>%@%@", RETCODE, RETCODE];
    
    if (_setting.isLeftOpen) {
        [retOpf appendFormat:@"<spine page-progression-direction=\"ltr\">%@%@", RETCODE, RETCODE];
    }
    else {
        [retOpf appendFormat:@"<spine page-progression-direction=\"rtl\">%@%@", RETCODE, RETCODE];
    }
    [retOpf appendFormat:@"<itemref linear=\"yes\" idref=\"p-cover\" properties=\"rendition:page-spread-center\"/>%@", RETCODE];
    
    [retOpf appendFormat:@"%@%@", itemref, RETCODE];
    
    [retOpf appendFormat:@"</spine>%@%@", RETCODE, RETCODE];
    [retOpf appendFormat:@"</package>%@", RETCODE];

    return [retOpf copy];
}

- (NSString*)makeNavigationDocuments:(NSMutableArray*)theDai
                    isAppendColophon:(BOOL)isAppendColophon
                     isWriteContents:(BOOL)isWriteContents
                           startPage:(int)startPage
{
    NSError *error = nil;
    NSMutableString *retNav = [NSMutableString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"nav_initial"]
                                                               encoding:NSUTF8StringEncoding
                                                                  error:&error];
    NSString *tmp = nil;
    NSMutableArray* mokujiXmlNames = [NSMutableArray array];
    NSMutableArray* sakuinXmlNames = [NSMutableArray array];
    
    [retNav appendString:RETCODE];
    
    if (!_setting.isNoContents) {
        NSMutableArray* arMokujiPageDai = [NSMutableArray array];
        NSArray *arMokujiPage = [_setting.mokujiPage componentsSeparatedByString:@","];
        if (arMokujiPage && arMokujiPage.count > 0) {
            for (NSString *p in arMokujiPage) {
                [arMokujiPageDai addObject:[NSNumber numberWithInt:[p intValue]]];
            }
            [arMokujiPageDai sortUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
                return [a compare:b];
            }];
        }
        else {
            return nil;
        }
        
        NSMutableArray* arMokujiContents = [_setting.theContents mutableCopy];
        [arMokujiContents sortUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
            if([a[@"con_page"] intValue] > [b[@"con_page"] intValue])
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if([a[@"con_page"] intValue] < [b[@"con_page"] intValue])
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }];
        
        NSMutableArray* sakuinIndexes = [NSMutableArray array];
        NSMutableArray* sakuinContents = [NSMutableArray array];
        
        for (NSNumber *num in arMokujiPageDai) {
            if ([self isSakuin:num]) {
                [sakuinIndexes addObject:[NSNumber numberWithUnsignedInteger:[arMokujiPageDai indexOfObject:num] + 1]];
            }
        }
        
        for (NSDictionary *row in arMokujiContents) {
            for (NSNumber *s in sakuinIndexes) {
                if ([row[@"con_page"] integerValue] == [s integerValue]) {
                    [sakuinContents addObject:row];
                }
            }
        }
        
        for (NSDictionary *row in sakuinContents) {
            [arMokujiContents removeObject:row];
        }
        
        BOOL isMokuji = NO;
        BOOL isWroteMokuji = NO;
        BOOL isWroteSakuin = NO;
        
        for (int i = 0; i < theDai.count; i++) {
            NSString *curFile = theDai[i][@"dai_filename"];
            int daiPageNum = [theDai[i][@"dai_page"] intValue];
            BOOL isContents = NO;
            BOOL isSakuin = NO;
            
            for (NSNumber *num in arMokujiPageDai) {
                if (daiPageNum == [num intValue]) {
                    if ([self isSakuin:num]) {
                        isSakuin = YES;
                    }
                    else {
                        isMokuji = (isWroteMokuji)? NO:YES;
                    }
                    break;
                }
            }
            
            NSMutableArray* pageContents = [NSMutableArray array];
            
            for(NSDictionary* row in arMokujiContents)
            {
                int contentPage = [row[@"con_page"] intValue];
                NSString* contentPageFileName = [NSString stringWithFormat:@"i-%@",[KZLibs paddNumber:3 num:contentPage]];
                
                if([KZLibs isEqual:contentPageFileName compare:curFile])
                {
                    isContents = YES;
                    [pageContents addObject:row[@"con_title"]];
                }
            }
            
            tmp = [self imageNameToXhtmlName:curFile];
            
            if (isWriteContents) {
                if (isMokuji && !isWroteMokuji) {
                    [mokujiXmlNames addObject:tmp];
                    NSString *cTitle = _setting.txtContentsPageTitle.stringValue;
                    if (EQ_STR(cTitle, @"")) {
                        cTitle = @"目次";
                    }
                    [retNav appendFormat:@"<li><a href=\"xhtml/%@\">%@</a></li>%@",tmp,cTitle,RETCODE];
                    isWroteMokuji = YES;
                }
                if (isSakuin && !isWroteSakuin) {
                    [sakuinXmlNames addObject:tmp];
                    [retNav appendFormat:@"<li><a href=\"xhtml/%@\">索引</a></li>%@",tmp,RETCODE];
                    isWroteSakuin = YES;
                }
                if (isContents) {
                    for (NSString *title in pageContents) {
                        [retNav appendFormat:@"<li><a href=\"xhtml/%@\">%@</a></li>%@",tmp,title,RETCODE];
                    }
                }
            }
            
            
        }
    }
    
    if (isAppendColophon) {
        [retNav appendFormat:@"<li><a href=\"xhtml/p-colophon.xhtml\">奥付</a></li>%@",RETCODE];
    }
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"nav_mid"]
                                    encoding:NSUTF8StringEncoding
                                      error:&error];
    [retNav appendFormat:@"%@%@",tmp,RETCODE];
    [retNav appendFormat:@"<li><a epub:type=\"cover\" href=\"xhtml/p-cover.xhtml\">表紙</a></li>%@",RETCODE];
    
    if (!_setting.isNoContents) {
        for (int i = 0; i < mokujiXmlNames.count; i++) {
            NSString* xhtml = mokujiXmlNames[i];
            tmp = [NSString stringWithFormat:@"<li><a epub:type=\"toc\"        href=\"xhtml/%@\">目次</a></li>%@",xhtml,RETCODE];
            if ((i + 1) == mokujiXmlNames.count) {
                [retNav appendString:tmp];
            }
            else {
                [retNav appendFormat:@"%@%@",tmp,RETCODE];
            }
        }
        for (int i = 0; i < sakuinXmlNames.count; i++) {
            NSString* xhtml = sakuinXmlNames[i];
            tmp = [NSString stringWithFormat:@"<li><a epub:type=\"toc\"        href=\"xhtml/%@\">索引</a></li>%@",xhtml,RETCODE];
            if ((i + 1) == sakuinXmlNames.count) {
                [retNav appendString:tmp];
            }
            else {
                [retNav appendFormat:@"%@%@",tmp,RETCODE];
            }
        }
    }
    int idx = startPage;
    tmp = theDai[idx-1][@"dai_filename"]; // 本編はカバーの次のページ
    if ([KZLibs isExistString:tmp searchStr:@"white"]) {
        // ただし、白の場合はその次のページ
        tmp = theDai[idx][@"dai_filename"];
    }
    tmp = [self imageNameToXhtmlName:tmp];
    tmp = [NSString stringWithFormat:@"<li><a epub:type=\"bodymatter\" href=\"xhtml/%@\">本編</a></li>%@",tmp,RETCODE];
    [retNav appendString:tmp];
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"nav_last"]
                                    encoding:NSUTF8StringEncoding
                                       error:&error];
    [retNav appendString:tmp];
    
    return [retNav copy];
}

- (NSString*)makeXmlInitial:(NSString*)fileName
{
    NSMutableString* ret = [NSMutableString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"xml_initial"] encoding:NSUTF8StringEncoding error:nil];
    
    [ret appendFormat:@"%@<title>%@</title>%@", RETCODE, _setting.title, RETCODE];
    [ret appendFormat:@"<link rel=\"stylesheet\" type=\"text/css\" href=\"../style/fixed-layout-jp.css\"/>%@", RETCODE];
    [ret appendFormat:@"<meta name=\"viewport\" content=\"width=%@, height=%@\"/>%@", _setting.orgWidth, _setting.orgHeight, RETCODE];
    [ret appendFormat:@"</head>%@", RETCODE];
    
    NSString* tmp = ([fileName isEqualToString:@"cover"])? @"<body epub:type=\"cover\">" : @"<body>";
    [ret appendFormat:@"%@%@", tmp, RETCODE];
    
    tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"xml_mid"] encoding:NSUTF8StringEncoding error:nil];

    [ret appendFormat:@"%@%@", tmp, RETCODE];
    
    [ret appendFormat:@" width=\"100%%\" height=\"100%%\" viewBox=\"0 0 %@ %@\">%@", _setting.orgWidth, _setting.orgHeight, RETCODE];
    
    [ret appendFormat:@"<image width=\"%@\" height=\"%@\" xlink:href=\"../image/%@.jpg\"/>%@", _setting.orgWidth, _setting.orgHeight, fileName, RETCODE];
    
    return [ret copy];
}

- (NSString*)xhtmlSource:(NSString*)fileName
{
    NSString* ret = [self makeXmlInitial:fileName];
    
    NSString* tmp = [NSString stringWithContentsOfFile:[RES_PATH stringByAppendingPathComponent:@"xml_end"] encoding:NSUTF8StringEncoding error:nil];

    return [ret stringByAppendingString:tmp];
}

- (void)makeXhtmls:(NSString*)xmlRoot theDai:(NSMutableArray*)theDai
{
    NSError *error = nil;
    
    // カバーデータを先に作る
    NSString* coverName = @"cover";
    NSString* scoverName = @"p-cover.xhtml";
    NSString* xhtmlData = [self xhtmlSource:coverName];
    NSString* xhtmlSavePath = [xmlRoot stringByAppendingPathComponent:scoverName];
    [xhtmlData writeToFile:xhtmlSavePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    for(int i = 0; i < theDai.count; i++)
    {
        NSString* fileName = theDai[i][@"dai_filename"];
        if (EQ_STR(fileName, @"cover"))
            continue;
        
        xhtmlData = [self xhtmlSource:fileName];
        fileName = [self imageNameToXhtmlName:fileName];
        xhtmlSavePath = [xmlRoot stringByAppendingPathComponent:fileName];
        [xhtmlData writeToFile:xhtmlSavePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
}

- (void)zipEpub:(NSString*)makeFolder targetDir:(NSString*)trgDir
{
    NSString *epubName = [[KZLibs getFileName:makeFolder] stringByAppendingString:@".epub"];
    NSString *epubAlias = [trgDir stringByAppendingPathComponent:epubName];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    BOOL carryOn = YES;
    @try {
        if ([fm fileExistsAtPath:epubAlias]) {
            [fm trashItemAtURL:[NSURL fileURLWithPath:epubAlias]
              resultingItemURL:nil error:nil];
        }
    }
    @catch (NSException *ex) {
        Log(ex.description);
        carryOn = NO;
    }
    
    if (!carryOn) return;
    
    NSString *cmd = [NSString stringWithFormat:@"cd \"%@\";zip -X0 \"%@\" mimetype", makeFolder, epubAlias];
    @try {
        NSArray *cmds = @[@"--login", @"-c", cmd];
        [KZLibs doShellScript:cmds];
    }
    @catch (NSException *ex) {
        Log(ex.description);
        carryOn = NO;
    }
    if (!carryOn) return;
    
    cmd = [NSString stringWithFormat:@"cd \"%@\";zip -rDX9 \"%@\" * -x \"*.DS_Store\" -x mimetype", makeFolder, epubAlias];
    @try {
        NSArray *cmds = @[@"--login", @"-c", cmd];
        [KZLibs doShellScript:cmds];
    }
    @catch (NSException *ex) {
        Log(ex.description);
        carryOn = NO;
    }
    if (!carryOn) return;
    return;
}

#pragma mark -
#pragma mark Public Funcs

- (BOOL)makeEPUB
{
    NSString *prjRoot = [_setting.projectPath path];
    prjRoot = [[[prjRoot stringByAppendingPathComponent:@"material"]
                 stringByAppendingPathComponent:_setting.eCode]
                stringByAppendingPathComponent:@"item"];
    NSString* imgPath = [prjRoot stringByAppendingPathComponent:@"image"];
    // navigation-documents.xhtml
    NSError *error = nil;
    NSString *navFile = [prjRoot stringByAppendingPathComponent:@"navigation-documents.xhtml"];
    NSString *navData = [self makeNavigationDocuments:[_setting.theDaiwari mutableCopy] isAppendColophon:YES isWriteContents:YES startPage:_setting.txtStartPage.intValue];
    [navData writeToFile:navFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString *opfFile = [prjRoot stringByAppendingPathComponent:@"standard.opf"];
    NSString *opfData = [self makeStandardOPF:[_setting.theDaiwari mutableCopy] ];
    [opfData writeToFile:opfFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self makeXhtmls:[prjRoot stringByAppendingPathComponent:@"xhtml"] theDai:[_setting.theDaiwari mutableCopy]];
    
    prjRoot = [_setting.projectPath path];
    NSString *epubSave = [prjRoot stringByAppendingPathComponent:@"release"];
    prjRoot = [[prjRoot stringByAppendingPathComponent:@"material"] stringByAppendingPathComponent:_setting.eCode];
    
    // 足りないファイルがあるかチェック
    BOOL isNoFile = NO;
    NSString *missFile;
    for (NSDictionary *d in _setting.theDaiwari) {
        if (![NSFileManager.defaultManager fileExistsAtPath:d[@"dai_path"]]) {
            isNoFile = YES;
            missFile = d[@"dai_path"];
        }
    }
    if (isNoFile) {
        NSAlert *al = [[NSAlert alloc] init];
        al.messageText = [NSString stringWithFormat:@"作成必要なファイルが足りません\n%@",missFile];
        [al beginSheetModalForWindow:_setting.windowForSheet completionHandler:^(NSModalResponse returnCode) {
        }];
        return NO;
    }
    
    // daiに存在しないファイルを削除
    NSArray *arImages = [KZLibs getFileList:imgPath deep:NO onlyDir:NO onlyFile:YES isAllFullPath:YES];
    for (NSString *iPath in arImages) {
        BOOL isFoundItem = NO;
        for (NSDictionary* d in _setting.theDaiwari) {
            if (EQ_STR(d[@"dai_path"], iPath)) {
                isFoundItem = YES;
                break;
            }
        }

        if (!isFoundItem) {
            [NSFileManager.defaultManager trashItemAtURL:[NSURL fileURLWithPath:iPath] resultingItemURL:nil error:nil];
        }
    }
    
    
    [self zipEpub:prjRoot targetDir:epubSave];
    
    return YES;
}

- (BOOL)makeTachiEPUB
{
    NSString *prjRoot = [[_setting.projectPath path] stringByAppendingPathComponent:@"material"];
    NSString* pPath;
    NSArray *folderList = [KZLibs getFileList:prjRoot deep:YES onlyDir:YES onlyFile:NO isAllFullPath:YES];
    for (NSString* folder in folderList) {
        if ([KZLibs isExistString:folder searchStr:@"item"] &&
            [KZLibs isExistString:folder searchStr:[_setting.eCode stringByAppendingString:@"/"]]) {
            pPath = folder;
            break;
        }
    }
    // Copy Image
    NSFileManager* fm = NSFileManager.defaultManager;
    NSMutableArray* theDai = [self getTachiRange];
    NSString *trgImagePath = [[prjRoot stringByAppendingPathComponent:[_setting.eCode stringByAppendingString:@"_t"]] stringByAppendingPathComponent:@"item/image"];
    for(NSDictionary *dai in theDai)
    {
        [fm copyItemAtPath:dai[@"dai_path"] toPath:[trgImagePath stringByAppendingPathComponent:[dai[@"dai_path"] lastPathComponent]] error:nil];
    }
    
    // navigation-documents.xhtml
    prjRoot = [[prjRoot stringByAppendingPathComponent:[_setting.eCode stringByAppendingString:@"_t"]] stringByAppendingPathComponent:@"item"];
    NSError *error = nil;
    NSString *navFile = [prjRoot stringByAppendingPathComponent:@"navigation-documents.xhtml"];
    NSString *navData = [self makeNavigationDocuments:theDai isAppendColophon:NO isWriteContents:YES startPage:_setting.txtStartPage.intValue];
    [navData writeToFile:navFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSString *opfFile = [prjRoot stringByAppendingPathComponent:@"standard.opf"];
    NSString *opfData = [self makeStandardOPF:[self getTachiRange]];
    [opfData writeToFile:opfFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    [self makeXhtmls:[prjRoot stringByAppendingPathComponent:@"xhtml"] theDai:[self getTachiRange]];
    
    prjRoot = [_setting.projectPath path];
    NSString *epubSave = [prjRoot stringByAppendingPathComponent:@"release"];
    prjRoot = [[prjRoot stringByAppendingPathComponent:@"material"] stringByAppendingPathComponent:[_setting.eCode stringByAppendingString:@"_t"]];
    
    [self zipEpub:prjRoot targetDir:epubSave];
    
    return YES;
}

- (BOOL)makeSplitEPUB
{
    NSString *prjRoot = [[_setting.projectPath path] stringByAppendingPathComponent:@"material"];
    NSString* sourcePath;
    NSArray *folderList = [KZLibs getFileList:prjRoot deep:YES onlyDir:YES onlyFile:NO isAllFullPath:YES];
    
    // itemフォルダ取得
    for (NSString* folder in folderList) {
        if ([KZLibs isExistString:folder searchStr:@"item"] &&
            [KZLibs isExistString:folder searchStr:[_setting.eCode stringByAppendingString:@"/"]]) {
            sourcePath = folder;
            break;
        }
    }
    
    // 分割フォルダ名
    int splitPage = _setting.splitPage.intValue;
    unsigned long fols = _setting.theSplits.count / splitPage;
    uint mod = _setting.theSplits.count % splitPage;
    NSMutableArray *arSplitFolders = [NSMutableArray array];
    
    for (int i = 0; i < fols; i++)
    {
        [arSplitFolders addObject:[NSString stringWithFormat:@"%@-%d", _setting.eCode,i+1]];
    }
    
    if (mod != 0) {
        [arSplitFolders addObject:[NSString stringWithFormat:@"%@-%lu", _setting.eCode,fols+1]];
    }
    
    // 各フォルダに画像コピー
    NSFileManager* fm = NSFileManager.defaultManager;
    NSMutableArray* theDai = [_setting.theSplits mutableCopy];
    
    int cpIdx = 0;
    int folIdx = 0;
    NSString *epubRoot = [[_setting.projectPath path] stringByAppendingPathComponent:@"release"];
    for (NSString* f in arSplitFolders)
    {
        // navigation-documents.xhtml
        
        NSError *error = nil;
        NSMutableArray *arDai = [self getSplitRange:folIdx cpIdx:cpIdx];
        
        NSString *trgImagePath = [[prjRoot stringByAppendingPathComponent:f] stringByAppendingPathComponent:@"item/image"];
        int trgPage = 0;
        if (folIdx == fols)
        {
            trgPage = mod + cpIdx;
        }
        else
        {
            trgPage = splitPage + cpIdx;
        }
        for(int i = cpIdx; i < trgPage; i++)
        {
            [fm copyItemAtPath:theDai[cpIdx][@"dai_path"] toPath:[trgImagePath stringByAppendingPathComponent:[theDai[cpIdx][@"dai_path"] lastPathComponent]] error:nil];
            cpIdx++;
        }
        
        // カバーのコピー
        [fm copyItemAtPath:_setting.theDaiwari[0][@"dai_path"] toPath:[trgImagePath stringByAppendingPathComponent:[_setting.theDaiwari[0][@"dai_path"] lastPathComponent]] error:nil];
        
        
        NSString *root = [trgImagePath stringByDeletingLastPathComponent];
        NSString *navFile = [root stringByAppendingPathComponent:@"navigation-documents.xhtml"];
        NSString *navData = [self makeNavigationDocuments:arDai isAppendColophon:NO isWriteContents:NO startPage:1];
        [navData writeToFile:navFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        NSString *opfFile = [root stringByAppendingPathComponent:@"standard.opf"];
        NSString *opfData = [self makeStandardOPF:arDai];
        [opfData writeToFile:opfFile atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        [self makeXhtmls:[root stringByAppendingPathComponent:@"xhtml"] theDai:arDai];
        
        root = [root stringByDeletingLastPathComponent];
        
        [self zipEpub:root targetDir:epubRoot];
        
        folIdx++;
    }
    
    
    
    return YES;
}
@end
