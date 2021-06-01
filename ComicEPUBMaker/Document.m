//
//  Document.m
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/23.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import "Document.h"
#import "SettingInfo.h"

@interface Document () <NSWindowDelegate>
@property (nonatomic, assign) BOOL isLoadSetting;
@property (nonatomic, retain) NSURL *loadFile;
@property (nonatomic, retain) SettingInfo *setting;

@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet NSPathControl *pPath;
@property (nonatomic, weak) IBOutlet NSTableView *tblDaiwari;
@property (nonatomic, weak) IBOutlet NSTableView *tblContents;
@property (nonatomic, weak) IBOutlet NSTableView *tblSplitFiles;

@property (nonatomic, weak) IBOutlet NSTextField *txtECode;
@property (nonatomic, weak) IBOutlet NSTextField *txtManageCode;
@property (nonatomic, weak) IBOutlet NSTextField *txtPublishDate;
@property (nonatomic, weak) IBOutlet NSTextField *txtTitle;
@property (nonatomic, weak) IBOutlet NSTextField *txtTitlePron;
@property (nonatomic, weak) IBOutlet NSTextField *txtAuthor;
@property (nonatomic, weak) IBOutlet NSTextField *txtAuthorPron;
@property (nonatomic, weak) IBOutlet NSTextField *txtMokujiPage;
@property (nonatomic, weak) IBOutlet NSTextField *txtColophonPage;
@property (nonatomic, weak) IBOutlet NSTextField *txtTachiRange;
@property (nonatomic, weak) IBOutlet NSTextField *txtStartPage;
@property (nonatomic, weak) IBOutlet NSTextField *txtWidth;
@property (nonatomic, weak) IBOutlet NSTextField *txtHeight;
@property (nonatomic, weak) IBOutlet NSTextField *txtJpgSize;
@property (nonatomic, weak) IBOutlet NSTextField *txtSplitPage;
@property (nonatomic, weak) IBOutlet NSButton *btnIsLeftOpen;

@property (nonatomic, weak) IBOutlet NSTextField *txtContentPageTitle;
@property (nonatomic, weak) IBOutlet NSTextField *txtContentsTitle;
@property (nonatomic, weak) IBOutlet NSTextField *txtContentsPage;
@property (nonatomic, weak) IBOutlet NSTextField *txtContentsPlacePage;

@property (nonatomic, weak) IBOutlet NSButton *goMakeProject;
@property (nonatomic, weak) IBOutlet NSButton *goMakeTachiyomi;
@property (nonatomic, weak) IBOutlet NSButton *goMakeFolder;
@property (nonatomic, weak) IBOutlet NSButton *goMakeEPUB;
@property (nonatomic, weak) IBOutlet NSButton *goMakeSplitEPUB;


- (IBAction)daiwariDelAll:(id)sender;
- (IBAction)daiwariDelSelect:(id)sender;
- (IBAction)daiwariMoveTop:(id)sender;
- (IBAction)daiwariMoveBottom:(id)sender;

- (IBAction)mokujiDelSelect:(id)sender;
- (IBAction)mokujiDelAll:(id)sender;
- (IBAction)mokujiDecide:(id)sender;
- (IBAction)mokujiDecidePage:(id)sender;

- (IBAction)makeProjectFolder:(id)sender;
- (IBAction)makeFolder:(id)sender;
- (IBAction)makeTachiyomi:(id)sender;
- (IBAction)makeEPUB:(id)sender;
- (IBAction)makeSplitEPUB:(id)sender;

- (IBAction)checkHon:(id)sender;
- (IBAction)checkSyo:(id)sender;

- (IBAction)splitDelSelect:(id)sender;
- (IBAction)splitDelAll:(id)sender;
@end

@implementation Document

static NSString* NSTableRowType = @"table.row";

#pragma marks -
#pragma marks Init

- (instancetype)init {
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        _isLoadSetting = NO;
        _loadFile = nil;
        _setting = [[SettingInfo alloc] init];
    }
    return self;
}

- (void)initSetting
{
    if (!_setting.isMadePrj) {
        NSURL *defPath = nil;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *defStr = ([ud stringForKey:@"PROJECT_PATH"])? [ud stringForKey:@"PROJECT_PATH"] : NSHomeDirectory();
        defPath = [NSURL fileURLWithPath:defStr];
        _setting.projectPath = defPath;
    }
    _setting.tabView = _tabView;
    _setting.tabView.delegate = _setting;
    
    _setting.pPath = _pPath;
    _setting.tblDaiwari = _tblDaiwari;
    _setting.tblContents = _tblContents;
    _setting.tblSplitFiles = _tblSplitFiles;
    
    _setting.txtECode = _txtECode;
    _setting.txtECode.delegate = _setting;
    
    _setting.txtTitle = _txtTitle;
    _setting.txtTitle.delegate = _setting;
    
    _setting.txtTitlePron = _txtTitlePron;
    _setting.txtTitlePron.delegate = _setting;
    
    _setting.txtAuthor = _txtAuthor;
    _setting.txtAuthor.delegate = _setting;
    
    _setting.txtAuthorPron = _txtAuthorPron;
    _setting.txtAuthorPron.delegate = _setting;
    
    _setting.txtPublishDate = _txtPublishDate;
    _setting.txtPublishDate.delegate = _setting;
    
    _setting.txtManageCode = _txtManageCode;
    _setting.txtManageCode.delegate = _setting;
    
    _setting.txtMokujiPage = _txtMokujiPage;
    _setting.txtMokujiPage.delegate = _setting;
    
    _setting.txtColophonPage = _txtColophonPage;
    _setting.txtColophonPage.delegate = _setting;
    
    _setting.txtTachiRange = _txtTachiRange;
    _setting.txtTachiRange.delegate = _setting;
    
    _setting.txtStartPage = _txtStartPage;
    _setting.txtStartPage.delegate = _setting;
    
    _setting.txtWidth = _txtWidth;
    _setting.txtWidth.delegate = _setting;
    
    _setting.txtHeight = _txtHeight;
    _setting.txtHeight.delegate = _setting;
    
    _setting.txtJpgSize = _txtJpgSize;
    
    _setting.txtSplitPage = _txtSplitPage;
    _setting.txtSplitPage.delegate = _setting;
    
    _setting.btnIsLeftOpen = _btnIsLeftOpen;
    
    _setting.pPath.delegate = _setting;
    _setting.pPath.target = _setting;
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"dai_page" ascending:YES selector:@selector(compare:)];
    [_setting.tblDaiwari registerForDraggedTypes:@[NSTableRowType,NSFilenamesPboardType]];
    _setting.tblDaiwari.target = _setting;
    _setting.tblDaiwari.delegate = _setting;
    _setting.tblDaiwari.dataSource = _setting;
    _setting.tblDaiwari.sortDescriptors = @[descriptor];
    
    _setting.tblContents.target = _setting;
    _setting.tblContents.delegate = _setting;
    _setting.tblContents.dataSource = _setting;
    
    _setting.tblSplitFiles.target = _setting;
    _setting.tblSplitFiles.delegate = _setting;
    _setting.tblSplitFiles.dataSource = _setting;
    _setting.tblSplitFiles.sortDescriptors = @[descriptor];
    [_setting.tblSplitFiles registerForDraggedTypes:@[NSTableRowType,NSFilenamesPboardType]];
    
    _setting.txtContentsPage = _txtContentsPage;
    _setting.txtContentsPageTitle = _txtContentPageTitle;
    _setting.txtContentsTitle = _txtContentsTitle;
    _setting.txtContentsPlacePage = _txtContentsPlacePage;
    
    _setting.goMakeEPUB = _goMakeEPUB;
    _setting.goMakeSplitEPUB = _goMakeSplitEPUB;
    _setting.goMakeProject = _goMakeProject;
    _setting.goMakeTachiyomi = _goMakeTachiyomi;
    _setting.goMakeFolder = _goMakeFolder;
    
    _setting.windowForSheet = self.windowForSheet;
    [_setting initIB];
}


#pragma marks -
#pragma marks Document

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    if (_setting) {
        [_setting updateDefPath];
    }
}

+ (BOOL)autosavesInPlace {
    return NO;
}


- (NSString *)windowNibName {
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [super windowControllerDidLoadNib:windowController];
    [self initSetting];
    [_setting appendToUI];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    if (*outError != NULL) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    [_setting appendFromUI];
    
    return [NSKeyedArchiver archivedDataWithRootObject:_setting];
}

- (BOOL)readFromURL:(NSURL *)url ofType:(NSString *)typeName error:(NSError * _Nullable __autoreleasing *)outError
{
    Log([url path]);
    NSData *data = [NSData dataWithContentsOfFile:[url path]];
    _setting = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _loadFile = url;
    _isLoadSetting = YES;
    if (*outError != NULL) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
        _isLoadSetting = NO;
    }
    
    return YES;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    [NSException raise:@"UnimplementedMethod" format:@"%@ is unimplemented", NSStringFromSelector(_cmd)];
    return YES;
}

#pragma marks -
#pragma marks Action
- (IBAction)daiwariDelAll:(id)sender
{
    [_setting daiwariDelAll];
}

- (IBAction)daiwariDelSelect:(id)sender
{
    [_setting daiwariDelSelect];
}

- (IBAction)daiwariMoveTop:(id)sender
{
    [_setting daiwariMoveTop];
}

- (IBAction)daiwariMoveBottom:(id)sender
{
    [_setting daiwariMoveBottom];
}

- (IBAction)mokujiDelSelect:(id)sender
{
    [_setting mokujiDelSelect];
}

- (IBAction)mokujiDelAll:(id)sender
{
    [_setting mokujiDelAll];
}

- (IBAction)mokujiDecide:(id)sender
{
    [_setting mokujiDecide];
}

- (IBAction)mokujiDecidePage:(id)sender
{
    [_setting mokujiDecidePage];
}

- (IBAction)makeFolder:(id)sender
{
    [_setting makeFolder];
}

- (IBAction)makeTachiyomi:(id)sender
{
    [_setting makeTachiyomi];
}

- (IBAction)makeEPUB:(id)sender
{
    [_setting makeEPUB];
}

- (IBAction)makeProjectFolder:(id)sender
{
    [_setting makeProjectFolder];
}

- (IBAction)checkHon:(id)sender
{
    [_setting checkHon];
}

- (IBAction)checkSyo:(id)sender
{
    [_setting checkSyo];
}

- (IBAction)makeSplitEPUB:(id)sender
{
    [_setting makeSplitEPUB];
}

- (IBAction)splitDelSelect:(id)sender
{
    [_setting splitDelSelect];
}

- (IBAction)splitDelAll:(id)sender
{
    [_setting splitDelAll];
}


@end
