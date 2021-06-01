//
//  SettingInfo.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/23.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "SettingInfo.h"
#import "MakeProjectFolder.h"
#import "MakeFolder.h"
#import "MakeEPUB.h"

@interface SettingInfo()
{
    
}
@property (nonatomic, retain) MakeProjectFolder *mk;
@property (nonatomic, retain) MakeFolder *mkf;
@property (nonatomic, retain) MakeEPUB *mke;
@end

@implementation SettingInfo

static NSString* NSTableRowType = @"table.row";

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    _theDaiwari = [NSArray array];
    _theContents = [NSArray array];
    _theSplits = [NSArray array];
    return self;
}

- (void)updateDefPath
{
    _isMadePrj = [_mk makeProject:NO];
    if (!_isMadePrj) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *defStr = ([ud stringForKey:@"PROJECT_PATH"])? [ud stringForKey:@"PROJECT_PATH"] : NSHomeDirectory();
        _projectPath = [NSURL fileURLWithPath:defStr];
        _pPath.URL = _projectPath;
    }
}

- (void)initIB
{
    _pPath.URL = _projectPath;
    _pPath.doubleAction = @selector(pathControlDoubleClick:);
    _tblDaiwari.doubleAction = @selector(onDoubleClickDaiwari:);
    _goMakeTachiyomi.enabled = NO;
    _goMakeFolder.enabled = NO;
    
    _mke = [[MakeEPUB alloc] init];
    _mkf = [[MakeFolder alloc] init];
    _mk = [[MakeProjectFolder alloc] init];
    
    _mk.setting = self;
    _mkf.setting = self;
    _mke.setting = self;
    
    _isMadePrj = [_mk makeProject:NO];
    _isMadeFolder = [_mkf makeFolder:NO];
    
    if (!_isMadePrj) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *defStr = ([ud stringForKey:@"PROJECT_PATH"])? [ud stringForKey:@"PROJECT_PATH"] : NSHomeDirectory();
        _projectPath = [NSURL fileURLWithPath:defStr];
        _pPath.URL = _projectPath;
    }
    
    [self changeButtonState];
    
    if (!_hanH) _hanH = _txtHeight.stringValue;
    if (!_hanW) _hanW = _txtWidth.stringValue;

    int calW = [self calcWidth:_hanW height:_hanH];
    _orgWidth = [NSNumber numberWithInt:calW];
    _orgHeight = [NSNumber numberWithInt:(int)MAKE_HEIGHT];
    
    _txtJpgSize.stringValue = [NSString stringWithFormat:@"%d x %d",[_orgWidth intValue], [_orgHeight intValue]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_eCode forKey:@"eCode"];
    [aCoder encodeObject:_manageCode forKey:@"manageCode"];
    [aCoder encodeObject:_author forKey:@"author"];
    [aCoder encodeObject:_authorPron forKey:@"authorPron"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_titlePron forKey:@"titlePron"];
    [aCoder encodeObject:_publishDate forKey:@"publishDate"];
    [aCoder encodeObject:_mokujiPage forKey:@"mokujiPage"];
    [aCoder encodeObject:_colophonPage forKey:@"colophonPage"];
    [aCoder encodeObject:_theDaiwari forKey:@"theDaiwari"];
    [aCoder encodeObject:_theContents forKey:@"theContents"];
    [aCoder encodeObject:_theSplits forKey:@"theSplits"];
    [aCoder encodeObject:_orgWidth forKey:@"orgWidth"];
    [aCoder encodeObject:_orgHeight forKey:@"orgHeight"];
    [aCoder encodeObject:_hanW forKey:@"hanW"];
    [aCoder encodeObject:_hanH forKey:@"hanH"];
    [aCoder encodeObject:_projectPath forKey:@"projectPath"];
    [aCoder encodeObject:_startPage forKey:@"startPage"];
    [aCoder encodeBool:_isNoContents forKey:@"isNoContents"];
    [aCoder encodeBool:_isLeftOpen forKey:@"isLeftOpen"];
    [aCoder encodeBool:_isMadePrj forKey:@"isMadePrj"];
    [aCoder encodeObject:_tachiRange forKey:@"tachiRange"];
    [aCoder encodeBool:_isMadeFolder forKey:@"isMadeFolder"];
    [aCoder encodeObject:_mokujiPageTitle forKey:@"contentsTitle"];
    [aCoder encodeObject:_splitPage forKey:@"splitPage"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.eCode = [aDecoder decodeObjectForKey:@"eCode"];
        self.manageCode = [aDecoder decodeObjectForKey:@"manageCode"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.authorPron = [aDecoder decodeObjectForKey:@"authorPron"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.titlePron = [aDecoder decodeObjectForKey:@"titlePron"];
        self.publishDate = [aDecoder decodeObjectForKey:@"publishDate"];
        self.mokujiPage = [aDecoder decodeObjectForKey:@"mokujiPage"];
        self.colophonPage = [aDecoder decodeObjectForKey:@"colophonPage"];
        self.theDaiwari = [[aDecoder decodeObjectForKey:@"theDaiwari"] mutableCopy];
        self.theContents = [[aDecoder decodeObjectForKey:@"theContents"] mutableCopy];
        if ([aDecoder containsValueForKey:@"theSplits"])
        {
            self.theSplits = [[aDecoder decodeObjectForKey:@"theSplits"] mutableCopy];
        }
        else {
            self.theSplits = [NSMutableArray array];
        }
        
        self.orgWidth = [aDecoder decodeObjectForKey:@"orgWidth"];
        self.orgHeight = [aDecoder decodeObjectForKey:@"orgHeight"];
        self.hanH = [aDecoder decodeObjectForKey:@"hanH"];
        self.hanW = [aDecoder decodeObjectForKey:@"hanW"];
        self.projectPath = [aDecoder decodeObjectForKey:@"projectPath"];
        self.startPage  = [aDecoder decodeObjectForKey:@"startPage"];
        self.isNoContents = [aDecoder decodeBoolForKey:@"isNoContents"];
        self.isLeftOpen = [aDecoder decodeBoolForKey:@"isLeftOpen"];
        self.tachiRange = [aDecoder decodeObjectForKey:@"tachiRange"];
        self.isMadePrj = [aDecoder decodeBoolForKey:@"isMadePrj"];
        self.isMadeFolder = [aDecoder decodeBoolForKey:@"isMadeFolder"];
        self.mokujiPageTitle = [aDecoder decodeObjectForKey:@"contentsTitle"];
        if ([aDecoder containsValueForKey:@"splitPage"]){
            self.splitPage = [aDecoder decodeObjectForKey:@"splitPage"];
        }
        
    }

    return self;
}


#pragma mark -
#pragma mark Local Funcs
- (int)calcWidth:(NSString*)strW height:(NSString*)strH
{
    double pixW = [KZLibs mmToPixcel:[strW doubleValue] dpi:MAKE_DPI];
    double pixH = [KZLibs mmToPixcel:[strH doubleValue] dpi:MAKE_DPI];
    
    double newW = roundf(pixW * MAKE_HEIGHT / pixH);
    
    return (int)newW;
}

- (void)appendJpgWidth
{
    int calW = [self calcWidth:_hanW height:_hanH];
    _orgWidth = [NSNumber numberWithInt:calW];
    _txtJpgSize.stringValue = [NSString stringWithFormat:@"%d x %d",[_orgWidth intValue], [_orgHeight intValue]];
}

- (void)changeButtonState
{
    BOOL isEcode = (_eCode && ![KZLibs isEqual:_eCode compare:@""]);
    BOOL isMcode = (_manageCode && ![KZLibs isEqual:_manageCode compare:@""]);
    BOOL isPubD = (_publishDate && ![KZLibs isEqual:_publishDate compare:@""]);
    BOOL isTitle = (_title && ![KZLibs isEqual:_title compare:@""]);
    BOOL isTitleP = (_titlePron && ![KZLibs isEqual:_titlePron compare:@""]);
    BOOL isAuth = (_author && ![KZLibs isEqual:_author compare:@""]);
    BOOL isAuthP = (_authorPron && ![KZLibs isEqual:_authorPron compare:@""]);
    BOOL isContP = (_mokujiPage && ![KZLibs isEqual:_mokujiPage compare:@""]);
    BOOL isColoP = (_colophonPage && ![KZLibs isEqual:_colophonPage compare:@""]);
    BOOL isStartP = (_startPage && ![KZLibs isEqual:_startPage compare:@""]);
    BOOL isTachi = (_tachiRange && ![KZLibs isEqual:_tachiRange compare:@""]);
    BOOL isDaiwari = (_theDaiwari && _theDaiwari.count > 0);
    BOOL isContents = (_theContents && _theContents.count > 0);
    BOOL isHanW = (_hanW && ![KZLibs isEqual:_hanW compare:@""]);
    BOOL isHanH = (_hanH && ![KZLibs isEqual:_hanH compare:@""]);
    
    if (isEcode && isTitle && isMcode) {
        _goMakeProject.enabled = YES;
    }
    else if (!isEcode || !isTitle || !isMcode) {
        _goMakeProject.enabled = NO;
    }
    
    if (_isMadePrj && isHanW && isHanH) {
        _goMakeFolder.enabled = YES;
    }
    else {
        _goMakeFolder.enabled = NO;
    }
    
    if (_isMadeFolder && _isMadePrj && isPubD && isTitleP && isAuth && isAuthP && isColoP && isDaiwari && isContents && isHanW && isHanH) {
        if (isContP) {
            _isNoContents = NO;
        }
        else {
            _isNoContents = YES;
        }
        
        if (isTachi) {
            _goMakeTachiyomi.enabled = YES;
        }
        else {
            _goMakeTachiyomi.enabled = NO;
        }
        
        _goMakeEPUB.enabled = YES;
    }
    else {
        _goMakeEPUB.enabled = NO;
        
        if (isContP) {
            _isNoContents = NO;
        }
        else {
            _isNoContents = YES;
        }
    }
}


- (void)setMokujiPage:(NSString*)mokuji
{
    NSMutableCharacterSet *set = [NSMutableCharacterSet decimalDigitCharacterSet];
    [set addCharactersInString:@","];
    NSRange rngStr = [mokuji rangeOfCharacterFromSet:[set copy]];
    
    if (rngStr.location == NSNotFound) {
        return;
    }
    
    mokuji = [self convertDelimiter:mokuji];
    _mokujiPage = mokuji;
    
    NSArray *arContentsPage = [_mokujiPage componentsSeparatedByString:@","];
    if (arContentsPage.count > 1) {
        NSString *val = [self getFileNameFromDaiPage:[arContentsPage[0] intValue]];
        _txtContentsPlacePage.stringValue = (val)?val:@"";
    }
    else {
        NSString *val = [self getFileNameFromDaiPage:[_mokujiPage intValue]];
        _txtContentsPlacePage.stringValue = (val)?val:@"";
    }
    
    _txtMokujiPage.stringValue = _mokujiPage;
}

- (void)resetDaiwariPage:(NSMutableArray*)arDai
{
    for (NSUInteger i = 0; i < arDai.count; i++) {
        NSMutableDictionary* muDic = [arDai[i] mutableCopy];
        muDic[@"dai_page"] = [NSNumber numberWithUnsignedInteger:i+1];
        arDai[i] = [muDic copy];
    }
}

- (NSString*)convertDelimiter:(NSString*)str
{
    str = [str stringByReplacingOccurrencesOfString:@"、" withString:@","];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"　" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"ー" withString:@"-"];
    return str;
}

- (NSString*)getFileNameFromDaiPage:(int)page
{
    NSString *retName = nil;
    if (_theDaiwari) {
        for(int i = 0; i < [_theDaiwari count];i++) {
            int daiPage = [_theDaiwari[i][@"dai_page"] intValue];
            if (page == daiPage) {
                retName = _theDaiwari[i][@"dai_filename"];
                break;
            }
        }
    }
    return retName;
}

#pragma mark -
#pragma mark Public Funcs

- (void)appendToUI
{
    (_eCode)? [_txtECode setStringValue:_eCode] : [_txtECode setStringValue:@""];
    (_manageCode)? [_txtManageCode setStringValue:_manageCode] : [_txtManageCode setStringValue:@""];
    (_publishDate)? [_txtPublishDate setStringValue:_publishDate] : [_txtPublishDate setStringValue:@""];
    (_title)? [_txtTitle setStringValue:_title] : [_txtTitle setStringValue:@""];
    (_titlePron)? [_txtTitlePron setStringValue:_titlePron] : [_txtTitlePron setStringValue:@""];
    (_colophonPage)? [_txtColophonPage setStringValue:_colophonPage] : [_txtColophonPage setStringValue:@""];
    [_btnIsLeftOpen setState:_isLeftOpen];
    (_startPage)? [_txtStartPage setStringValue:_startPage] : [_txtStartPage setStringValue:@""];
    (_author)? [_txtAuthor setStringValue:_author] : [_txtAuthor setStringValue:@""];
    (_authorPron)? [_txtAuthorPron setStringValue:_authorPron] : [_txtAuthorPron setStringValue:@""];
    (_tachiRange)? [_txtTachiRange setStringValue:_tachiRange] : [_txtTachiRange setStringValue:@""];
    (_mokujiPageTitle)? [_txtContentsPageTitle setStringValue:_mokujiPageTitle] : [_txtContentsPageTitle setStringValue:@""];
    NSString *homePath = [NSURL fileURLWithPath:NSHomeDirectory()].absoluteString;
    if (_projectPath || ![KZLibs isEqual:_projectPath.absoluteString compare:homePath]) {
        _pPath.URL = _projectPath;
    }
    else {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *defStr = ([ud stringForKey:@"PROJECT_PATH"])? [ud stringForKey:@"PROJECT_PATH"] : NSHomeDirectory();
        NSURL *defPath = [NSURL fileURLWithPath:defStr];
        _pPath.URL = defPath;
    }
    
    if (_mokujiPage) {
        [self setMokujiPage:_mokujiPage];
    }
    else {
        _txtMokujiPage.stringValue = @"";
        _txtContentsPlacePage.stringValue = @"";
    }
    
    if (_hanH) {
        _txtHeight.stringValue = _hanH;
        if (_hanW) {
            [self appendJpgWidth];
        }
    }
    else {
        _hanH = HAN_HEIGHT;
    }
    
    if (_hanW) {
        _txtWidth.stringValue = _hanW;
        [self appendJpgWidth];
    }
    else {
        _hanH = HAN_WIDTH;
        [self appendJpgWidth];
    }
}

- (void)appendFromUI
{
    _eCode = _txtECode.stringValue;
    _manageCode = _txtManageCode.stringValue;
    _publishDate = _txtPublishDate.stringValue;
    _title = _txtTitle.stringValue;
    _titlePron = _txtTitlePron.stringValue;
    _colophonPage = _txtColophonPage.stringValue;
    _projectPath = _pPath.URL;
    _isLeftOpen = _btnIsLeftOpen.state;
    _startPage = _txtStartPage.stringValue;
    _author = _txtAuthor.stringValue;
    _authorPron = _txtAuthorPron.stringValue;
    _mokujiPage = _txtMokujiPage.stringValue;
    _tachiRange = _txtTachiRange.stringValue;
    _mokujiPageTitle = _txtContentsPageTitle.stringValue;
}

- (void)setProjectPathBar:(NSString*)p
{
    _pPath.URL = [NSURL fileURLWithPath:p];
}

- (void)daiwariDelAll
{
    _theDaiwari = [NSArray array];
    [_tblDaiwari reloadData];
}

- (void)daiwariDelSelect
{
    NSMutableArray *tmpArray = [_theDaiwari mutableCopy];
    
    [tmpArray removeObjectAtIndex:_tblDaiwari.selectedRow];
    [self resetDaiwariPage:tmpArray];
    _theDaiwari = [tmpArray copy];
    [_tblDaiwari reloadData];
    [_tblDaiwari selectRowIndexes:[NSIndexSet indexSetWithIndex:_tblDaiwari.selectedRow] byExtendingSelection:YES];
}

- (void)daiwariMoveTop
{
    NSIndexSet *rowIndexes = _tblDaiwari.selectedRowIndexes;
    NSMutableArray *tmpArray = [_theDaiwari mutableCopy];
    NSMutableArray *insertArray = [NSMutableArray array];
    NSMutableIndexSet *insertIndexes = [NSMutableIndexSet indexSet];
    
    __block int i = 0;
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *obj = [[NSMutableDictionary alloc] initWithDictionary:tmpArray[idx]];
        [insertArray addObject:obj];
        [insertIndexes addIndex:i];
        i++;
    }];
    
    [tmpArray removeObjectsInArray:[insertArray copy]];
    [tmpArray insertObjects:insertArray atIndexes:[insertIndexes copy]];
    [self resetDaiwariPage:tmpArray];
    _theDaiwari = [tmpArray mutableCopy];
    [_tblDaiwari reloadData];
    [_tblDaiwari selectRowIndexes:insertIndexes byExtendingSelection:YES];
    [_tblDaiwari scrollRowToVisible:0];
}

- (void)daiwariMoveBottom
{
    NSIndexSet *rowIndexes = _tblDaiwari.selectedRowIndexes;
    NSMutableArray *tmpArray = [_theDaiwari mutableCopy];

    NSMutableArray *insertArray = [NSMutableArray array];
    NSMutableIndexSet *insertIndexes = [NSMutableIndexSet indexSet];
    __block NSUInteger i = tmpArray.count - rowIndexes.count;
    
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *obj = [[NSMutableDictionary alloc] initWithDictionary:tmpArray[idx]];
        [insertArray addObject:obj];
        [insertIndexes addIndex:i];
        i++;
    }];
    
    [tmpArray removeObjectsInArray:[insertArray copy]];
    [tmpArray insertObjects:insertArray atIndexes:[insertIndexes copy]];
    [self resetDaiwariPage:tmpArray];
    _theDaiwari = [tmpArray mutableCopy];
    [_tblDaiwari reloadData];
    [_tblDaiwari selectRowIndexes:insertIndexes byExtendingSelection:YES];
    [_tblDaiwari scrollRowToVisible:tmpArray.count - 1];
}

- (void)mokujiDelSelect
{
    NSMutableArray *tmpArray = [_theContents mutableCopy];
    
    [tmpArray removeObjectAtIndex:_tblContents.selectedRow];
    _theContents = [tmpArray copy];
    [_tblContents reloadData];
    [_tblContents selectRowIndexes:[NSIndexSet indexSetWithIndex:_tblContents.selectedRow] byExtendingSelection:YES];
}

- (void)mokujiDelAll
{
    _theContents = [NSArray array];
    [_tblContents reloadData];
}

- (void)mokujiDecide
{
    [_txtContentsPage becomeFirstResponder];
}

- (void)mokujiDecidePage
{
    NSMutableArray *tmpArray = [_theContents mutableCopy];
    
    NSString* pageData = _txtContentsPage.stringValue;
    NSString* contentsData = _txtContentsTitle.stringValue;
    if ([KZLibs isEqual:pageData compare:@""] || [KZLibs isEqual:contentsData compare:@""]) {
        [_txtContentsTitle becomeFirstResponder];
        return;
    }
    
    NSDictionary *addObj = @{@"con_no" : _txtContentsPlacePage.stringValue,
                             @"con_page" : pageData,
                             @"con_title" : contentsData};
    [tmpArray addObject:addObj];
    _theContents = [tmpArray copy];
    [_tblContents reloadData];

    NSIndexSet* newRow = [NSIndexSet indexSetWithIndex:_theContents.count - 1];
    [_tblContents selectRowIndexes:newRow byExtendingSelection:YES];
    [_tblContents scrollRowToVisible:_theContents.count - 1];
    _txtContentsPage.stringValue = @"";
    _txtContentsTitle.stringValue = @"";
    [_txtContentsTitle becomeFirstResponder];
}

- (void)makeProjectFolder
{
    _mk.setting = self;
    _isMadePrj = [_mk makeProject:YES];
    _projectPath = [NSURL fileURLWithPath:_mk.projectFolder];
    _pPath.URL = _projectPath;
    [self changeButtonState];
}

- (void)makeFolder
{
    _mkf.setting = self;
    _isMadeFolder = [_mkf makeFolder:YES];
    [self changeButtonState];
}

- (void)makeTachiyomi
{
    _mkf.setting = self;
    if (![_mkf makeTachiFolder]) {
        return;
    }
    
    _mke.setting = self;
    [_mke makeTachiEPUB];
}

- (void)makeEPUB
{
    if (![_mke makeEPUB]) {
        Log(@"Error Make EPUB");
    }
}

- (void)makeSplitEPUB
{
    NSInteger intVal = [_txtSplitPage intValue];
    _splitPage = [NSNumber numberWithInteger:intVal];
    _mkf.setting = self;
    if (![_mkf makeSplitFolder]) {
        return;
    }
    _mke.setting = self;
    if (![_mke makeSplitEPUB]) {
        Log(@"Error Make Split EPUB");
    }
}

- (void)checkHon
{
    NSAlert *al = [[NSAlert alloc] init];
    NSMutableString *alMessage = [[NSMutableString alloc] init];
    
    NSString *tmp = [[[_projectPath path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:PRJ_4_FOLDER];
    NSArray *arNouhin = [KZLibs getFileList:tmp
                                       deep:NO onlyDir:YES onlyFile:NO isAllFullPath:YES];
    if (arNouhin.count == 0) return;
    
    NSString *nouhinRoot = arNouhin[0];
    
    
    NSArray *nouhinFols = @[
                            [nouhinRoot stringByAppendingPathComponent:@"EPUB"],
                            [nouhinRoot stringByAppendingPathComponent:@"カバー（サムネイル含む）"],
                            [nouhinRoot stringByAppendingPathComponent:@"背"],
                            [nouhinRoot stringByAppendingPathComponent:@"TIFF"]
                            ];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *se = [_eCode stringByAppendingString:@"_se.jpg"];
    NSString *co = [_eCode stringByAppendingString:@".jpg"];
    NSString *ep = [_eCode stringByAppendingString:@".epub"];
    NSString *ep_t = [_eCode stringByAppendingString:@".epub"];
    
    for (NSString *fol in nouhinFols) {
        if ([KZLibs isExistString:[fol lastPathComponent] searchStr:@"EPUB"]) {
            if ([fm fileExistsAtPath:[fol stringByAppendingPathComponent:ep]]) {
                [fm trashItemAtURL:[NSURL fileURLWithPath:[fol stringByAppendingPathComponent:ep]] resultingItemURL:nil error:nil];
            }
            
            NSString *epData = [[[_projectPath path] stringByAppendingPathComponent:@"release"] stringByAppendingPathComponent:ep];
            NSString *ep_tData = [[[_projectPath path] stringByAppendingPathComponent:@"release"] stringByAppendingPathComponent:ep_t];
            if (![fm fileExistsAtPath:epData]) {
                [alMessage appendString:@"EPUBデータが存在しません\n"];
            }
            else {
                [fm copyItemAtPath:epData toPath:[fol stringByAppendingPathComponent:ep] error:nil];
            }
            
            if (![fm fileExistsAtPath:ep_tData] && _tachiRange && NEQ_STR(_tachiRange, @"")) {
                [alMessage appendString:@"EPUBデータ(立ち読み)が存在しません\n"];
            }
            else {
                [fm copyItemAtPath:ep_tData toPath:[fol stringByAppendingPathComponent:ep_t] error:nil];
            }
            
        }
        else if ([KZLibs isExistString:[fol lastPathComponent] searchStr:@"カバー"]) {
            if ([fm fileExistsAtPath:[fol stringByAppendingPathComponent:co]]) {
                [fm trashItemAtURL:[NSURL fileURLWithPath:[fol stringByAppendingPathComponent:co]] resultingItemURL:nil error:nil];
            }
            
            NSString *cvData = [[_projectPath path] stringByAppendingPathComponent:[NSString stringWithFormat:@"material/%@/item/image/cover.jpg", _eCode]];
            if (![fm fileExistsAtPath:cvData]) {
                [alMessage appendString:@"カバーデータが存在しません\n"];
            }
            else {
                [fm copyItemAtPath:cvData toPath:[fol stringByAppendingPathComponent:co] error:nil];
            }
            
        }
        else if ([KZLibs isExistString:[fol lastPathComponent] searchStr:@"背"]) {
            if (![fm fileExistsAtPath:[fol stringByAppendingPathComponent:se]]) {
                [alMessage appendString:@"カバー背のデータを入れてください\n"];
            }
        }
        
    }

    if (![KZLibs isEqual:alMessage compare:@""]) {
        al.messageText = alMessage;
        [al beginSheetModalForWindow:_windowForSheet completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

- (void)checkSyo
{
    NSAlert *al = [[NSAlert alloc] init];
    NSMutableString *alMessage = [[NSMutableString alloc] init];
    NSString *tmp = [[[_projectPath path] stringByDeletingLastPathComponent] stringByAppendingPathComponent:PRJ_4_FOLDER];
    NSArray *arNouhin = [KZLibs getFileList:tmp
                                       deep:NO onlyDir:YES onlyFile:NO isAllFullPath:YES];
    if (arNouhin.count == 0) return;
    
    arNouhin = [KZLibs getFileList:arNouhin[0]
                              deep:NO onlyDir:YES onlyFile:NO isAllFullPath:YES];
    
    if (arNouhin.count == 0) return;
    NSString *syokou = nil;

    for (NSString *fol in arNouhin) {
        NSString *fn = [KZLibs getFileName:fol];
        if ([KZLibs isExistString:fn searchStr:@"EPUB"]) {
            syokou = fol;
        }
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *ep = [_eCode stringByAppendingString:@".epub"];
    NSString *ep_t = [_eCode stringByAppendingString:@"_t.epub"];
    
    if (![fm fileExistsAtPath:[syokou stringByAppendingPathComponent:ep]]) {
        NSString *epData = [[[_projectPath path] stringByAppendingPathComponent:@"release"] stringByAppendingPathComponent:ep];
        if (![fm fileExistsAtPath:epData]) {
            [alMessage appendString:@"EPUBデータが存在しません\n"];
        }
        else {
            [fm copyItemAtPath:epData toPath:[syokou stringByAppendingPathComponent:ep] error:nil];
        }
    }
    
    if (![fm fileExistsAtPath:[syokou stringByAppendingPathComponent:ep_t]]) {
        NSString *epData = [[[_projectPath path] stringByAppendingPathComponent:@"release"] stringByAppendingPathComponent:ep_t];
        if (![fm fileExistsAtPath:epData] && _tachiRange && NEQ_STR(_tachiRange, @"")) {
            [alMessage appendString:@"EPUBデータ(立ち読み)が存在しません\n"];
        }
        else {
            [fm copyItemAtPath:epData toPath:[syokou stringByAppendingPathComponent:ep_t] error:nil];
        }
    }
    
    if (![KZLibs isEqual:alMessage compare:@""]) {
        al.messageText = alMessage;
        [al beginSheetModalForWindow:_windowForSheet completionHandler:^(NSModalResponse returnCode) {
        }];
    }
}

- (void)splitDelSelect
{
    NSMutableArray *tmpArray = [_theSplits mutableCopy];
    
    [tmpArray removeObjectAtIndex:_tblSplitFiles.selectedRow];
    _theSplits = [tmpArray copy];
    [_tblSplitFiles reloadData];
    [_tblSplitFiles selectRowIndexes:[NSIndexSet indexSetWithIndex:_tblSplitFiles.selectedRow] byExtendingSelection:YES];
}
- (void)splitDelAll
{
    _theSplits = [NSArray array];
    [_tblSplitFiles reloadData];
}

#pragma mark -
#pragma mark Action

- (void)pathControlDoubleClick:(id)sender
{
    if ([self.pPath clickedPathComponentCell] != nil)
    {
        [[NSWorkspace sharedWorkspace] openURL:self.pPath.clickedPathComponentCell.URL];
    }
}

-(void)onDoubleClickDaiwari:(id)sender
{
    if([sender clickedRow] == -1) return;
    NSMutableDictionary* selData = _theDaiwari[[sender clickedRow]];
    NSURL* folderURL = [NSURL fileURLWithPath:selData[@"dai_path"]];
    [[NSWorkspace sharedWorkspace] openURL:folderURL];
}


#pragma mark -
#pragma mark DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        return _theDaiwari.count;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"contents"]) {
        return _theContents.count;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        return _theSplits.count;
    }
    return 0;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    NSData *indexSetWithData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
    [item setData:indexSetWithData forType:NSTableRowType];
    [pboard writeObjects:@[item]];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    NSArray *theDatas = nil;
    
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        theDatas = _theDaiwari;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"contents"]) {
        theDatas = _theContents;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        theDatas = _theSplits;
    }
    
    if (row > theDatas.count || row < 0) {
        return NSDragOperationNone;
    }
    
    if (!info.draggingSource) {
        return NSDragOperationCopy;
    }
    else if (info.draggingSource == self) {
        return NSDragOperationNone;
    }
    else if (info.draggingSource == tableView) {
        [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
        return NSDragOperationMove;
    }
    return NSDragOperationCopy;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *data = nil;
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        data = _theDaiwari[row];
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"contents"]) {
        data = _theContents[row];
        cell.textField.editable = YES;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        data = _theSplits[row];
        cell.textField.editable = YES;
    }
   
    cell.objectValue = data[identifier];
    cell.textField.stringValue = data[identifier];
    cell.identifier = [identifier stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)row]];
    cell.textField.delegate = self;
    cell.textField.cell.representedObject = @{@"Col" : identifier,
                                              @"Row" : [NSNumber numberWithInteger:row]};
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    BOOL isDaiwari = YES;
    BOOL isSplit = YES;
    NSTableView *dragSource = info.draggingSource;
    if (dragSource != NULL) {
        if (![KZLibs isEqual:dragSource.identifier compare:tableView.identifier]) {
            return NO;
        }
    }
    NSPasteboard *pb = info.draggingPasteboard;
    NSArray *arTypes = pb.types;
    
    NSMutableArray *theDatas = nil;
    
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        theDatas = [_theDaiwari mutableCopy];
        isSplit = NO;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"contents"]) {
        theDatas = [_theContents mutableCopy];
        isDaiwari = NO;
        isSplit = NO;
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        theDatas = [_theSplits mutableCopy];
        isDaiwari = NO;
    }
    
    for (NSString *type in arTypes) {
        if ([KZLibs isEqual:type compare:NSFilenamesPboardType]) {
            // File Drop To Table View
            NSData *data = [pb dataForType:NSFilenamesPboardType];
            NSError *error;
            NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
            NSArray *theFiles = [NSPropertyListSerialization
                                 propertyListWithData:data
                                 options:(NSPropertyListReadOptions)NSPropertyListImmutable
                                 format:&format
                                 error:&error];
            if (error) {
                LogF(@"get file property error : %@", error.description);
                break;
            }
            if (!theFiles) {
                Log(@"get file property error");
                break;
            }
            
            for (NSUInteger i = 0; i < theFiles.count; i++) {
                // only Daiwari Table!!
                if (isDaiwari || isSplit) {
                    if ([KZLibs isDirectory:theFiles[i]]) {
                        NSArray *arFiles = [KZLibs getFileList:theFiles[i] deep:NO onlyDir:NO onlyFile:YES isAllFullPath:YES];
                        for (NSUInteger j = 0; j < arFiles.count; j++) {
                            NSDictionary *setData = @{@"dai_page" : [NSNumber numberWithUnsignedInteger:(NSUInteger)theDatas.count + 1],
                                                      @"dai_filename" : [KZLibs getFileName:arFiles[j]],
                                                      @"dai_path" : arFiles[j]};
                            NSMutableDictionary *setDic = [[NSMutableDictionary alloc] initWithDictionary:setData];
                            [theDatas addObject:setDic];
                        }
                    }
                    else {
                        NSDictionary *setData = @{@"dai_page" : [NSNumber numberWithUnsignedInteger:(NSUInteger)theDatas.count + 1],
                                                  @"dai_filename" : [KZLibs getFileName:theFiles[i]],
                                                  @"dai_path" : theFiles[i]};
                        NSMutableDictionary *setDic = [[NSMutableDictionary alloc] initWithDictionary:setData];
                        [theDatas addObject:setDic];
                    }
                }
            }
            if (isDaiwari) _theDaiwari = [theDatas mutableCopy];
            if (isSplit) _theSplits = [theDatas mutableCopy];
            [tableView reloadData];
        }
        else if ([KZLibs isEqual:type compare:NSTableRowType]) {
            // Row Drop To Table View
            // only Daiwari Table!!
            
            NSData *data = [pb dataForType:NSTableRowType];
            NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];

            if (isDaiwari || isSplit) {
                __block NSUInteger i = 0;
                NSMutableArray *insertArray = [NSMutableArray array];
                NSMutableIndexSet *insertIndexes = [NSMutableIndexSet indexSet];
                NSInteger first = rowIndexes.firstIndex;
                
                if (row == theDatas.count) {
                    // insert last
                    i = theDatas.count - rowIndexes.count;
                }
                else if (row == theDatas.count - 1) {
                    i = (theDatas.count - rowIndexes.count) - 1;
                }
                else if (row <= 0) {
                    i = 0;
                }
                else if (row == 1) {
                    i = 1;
                }
                else {
                    i = (row < first)? row : row - rowIndexes.count;
                }
                
                [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
                    NSMutableDictionary *obj = [[NSMutableDictionary alloc] initWithDictionary:theDatas[idx]];
                    [insertArray addObject:obj];
                    [insertIndexes addIndex:i];
                    i++;
                }];
                
                [theDatas removeObjectsInArray:[insertArray copy]];
                [theDatas insertObjects:insertArray atIndexes:[insertIndexes copy]];
                [self resetDaiwariPage:theDatas];
                if (isDaiwari) _theDaiwari = [theDatas mutableCopy];
                if (isSplit) _theSplits = [theDatas mutableCopy];
                [tableView reloadData];
                [tableView selectRowIndexes:insertIndexes byExtendingSelection:YES];
            }
        }
    }
    return YES;
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray<NSSortDescriptor *> *)oldDescriptors
{
    NSMutableArray *ardai = [NSMutableArray array];
    
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        ardai = [_theDaiwari mutableCopy];
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        ardai = [_theSplits mutableCopy];
    }
    
    [ardai sortUsingDescriptors:[tableView sortDescriptors]];
    for (int i = 0; i < ardai.count; i++) {
        NSMutableDictionary *muDic = [ardai[i] mutableCopy];
        muDic[@"dai_page"] = [NSNumber numberWithUnsignedInteger:(NSUInteger)i + 1];
        ardai[i] = [muDic copy];
    }
    if ([KZLibs isEqual:tableView.identifier compare:@"daiwari"]) {
        _theDaiwari = [ardai copy];
    }
    else if ([KZLibs isEqual:tableView.identifier compare:@"split"]) {
        _theSplits = [ardai copy];
    }
    
    [tableView reloadData];
}

#pragma mark -
#pragma mark Delegate

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self changeButtonState];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tbl = notification.object;
    if ([KZLibs isEqual:tbl.identifier compare:@"contents"]) {
        NSInteger row = tbl.selectedRow;
        if (row < 0) {
            _txtContentsTitle.stringValue = @"";
            _txtContentsPage.stringValue = @"";
        }
        else {
            NSDictionary *data = _theContents[row];
            _txtContentsPlacePage.stringValue = data[@"con_no"];
            _txtContentsTitle.stringValue = data[@"con_title"];
            _txtContentsPage.stringValue = data[@"con_page"];
        }
    }
}

/*
 This method is called when an item is dragged over the control. Return NSDragOperationNone to refuse the drop, or anything else to accept it.
 */
- (NSDragOperation)pathControl:(NSPathControl *)pathControl validateDrop:(id <NSDraggingInfo>)info
{
    return NSDragOperationCopy;
}


/*
 Implement this method to accept the dropped contents previously accepted from validateDrop:.  Get the new URL from the pasteboard and set it to the path control.
 */
-(BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info
{
    BOOL result = NO;
    
    NSURL *URL = [NSURL URLFromPasteboard:[info draggingPasteboard]];
    if (URL != nil)
    {
        [self.pPath setURL:URL];
        result = YES;
    }
    
    return result;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    
    NSTextField* field = (NSTextField*)obj.object;
    NSString *fieldString = field.stringValue.precomposedStringWithCanonicalMapping;
    field.stringValue = fieldString;
    
    if (field.cell.representedObject) {
        NSNumber *row = field.cell.representedObject[@"Row"];
        NSMutableArray *arTmp = [_theContents mutableCopy];
        NSMutableDictionary *dicTmp = [arTmp[row.unsignedIntegerValue] mutableCopy];
        if ([KZLibs isEqual:(NSString*)field.cell.representedObject[@"Col"] compare:@"con_no"]) {
            dicTmp[@"con_no"] = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.cell.representedObject[@"Col"] compare:@"con_page"]) {
            dicTmp[@"con_page"] = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.cell.representedObject[@"Col"] compare:@"con_title"]) {
            dicTmp[@"con_title"] = field.stringValue;
        }
        arTmp[row.unsignedIntegerValue] = dicTmp;
        _theContents = [arTmp copy];
    }
    else {
        if ([KZLibs isEqual:(NSString*)field.identifier compare:@"eCode"]) {
            _eCode = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"splitpage"])
        {
            NSInteger intVal = [_txtSplitPage intValue];
            _splitPage = [NSNumber numberWithInteger:intVal];
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"manageCode"]) {
            _manageCode = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"publishDate"]) {
            _publishDate = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"title"]) {
            _title = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"titlePron"]) {
            _titlePron = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"author"]) {
            NSString* strAuth = field.stringValue;
            //strAuth = [self convertDelimiter:strAuth];
            field.stringValue = strAuth;
            _author = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"authorPron"]) {
            NSString* strAuth = field.stringValue;
            //strAuth = [self convertDelimiter:strAuth];
            field.stringValue = strAuth;
            _authorPron = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"mokujiPage"]) {
            [self setMokujiPage:field.stringValue];
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"colophonPage"]) {
            _colophonPage = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"tachiRange"]) {
            NSString *strRange = field.stringValue;
            strRange = [self convertDelimiter:strRange];
            field.stringValue = strRange;
            _tachiRange = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"startPage"]) {
            _startPage = field.stringValue;
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"hanW"]) {
            _hanW = field.stringValue;
            if (_hanH) {
                [self appendJpgWidth];
            }
        }
        else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"hanH"]) {
            _hanH = field.stringValue;
            _orgHeight = [NSNumber numberWithInt:(int)MAKE_HEIGHT];
            if (_hanW) {
                [self appendJpgWidth];
            }
            
        }
        [self changeButtonState];
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    NSTextField* field = (NSTextField*)control;
    NSString *fieldString = field.stringValue.precomposedStringWithCanonicalMapping;
    field.stringValue = fieldString;
    
    if ([KZLibs isEqual:(NSString*)field.identifier compare:@"eCode"]) {
        _eCode = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"manageCode"]) {
        _manageCode = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"publishDate"]) {
        _publishDate = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"title"]) {
        _title = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"titlePron"]) {
        _titlePron = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"author"]) {
        _author = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"authorPron"]) {
        _authorPron = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"mokujiPage"]) {
        _mokujiPage = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"colophonPage"]) {
        _colophonPage = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"tachiRange"]) {
        _tachiRange = field.stringValue;
    }
    else if ([KZLibs isEqual:(NSString*)field.identifier compare:@"startPage"]) {
        _startPage = field.stringValue;
    }
    return YES;
}
@end
