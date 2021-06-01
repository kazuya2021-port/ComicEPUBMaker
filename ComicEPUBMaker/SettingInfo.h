//
//  SettingInfo.h
//  ComicEPUBMaker
//
//  Created by uchiyama_Macmini on 2019/04/23.
//  Copyright © 2019年 uchiyama_Macmini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingInfo : NSObject <NSCoding, NSControlTextEditingDelegate, NSTableViewDataSource, NSTableViewDelegate, NSPathControlDelegate, NSTextFieldDelegate, NSTabViewDelegate>
@property (nonatomic, weak) NSTabView *tabView;
@property (nonatomic, weak) NSWindow *windowForSheet;
@property (nonatomic, weak) NSPathControl *pPath;
@property (nonatomic, weak) NSTableView *tblDaiwari;
@property (nonatomic, weak) NSTableView *tblContents;
@property (nonatomic, weak) NSTableView *tblSplitFiles;

@property (nonatomic, weak) NSTextField *txtECode;
@property (nonatomic, weak) NSTextField *txtManageCode;
@property (nonatomic, weak) NSTextField *txtPublishDate;
@property (nonatomic, weak) NSTextField *txtTitle;
@property (nonatomic, weak) NSTextField *txtTitlePron;
@property (nonatomic, weak) NSTextField *txtAuthor;
@property (nonatomic, weak) NSTextField *txtAuthorPron;
@property (nonatomic, weak) NSTextField *txtMokujiPage;
@property (nonatomic, weak) NSTextField *txtColophonPage;
@property (nonatomic, weak) NSTextField *txtTachiRange;
@property (nonatomic, weak) NSTextField *txtStartPage;
@property (nonatomic, weak) NSTextField *txtWidth;
@property (nonatomic, weak) NSTextField *txtHeight;
@property (nonatomic, weak) NSTextField *txtJpgSize;
@property (nonatomic, weak) NSTextField *txtSplitPage;
@property (nonatomic, weak) NSTextField *txtSplitLastPage;
@property (nonatomic, weak) NSButton *btnIsLeftOpen;

@property (nonatomic, weak) NSTextField *txtContentsPlacePage;
@property (nonatomic, weak) NSTextField *txtContentsTitle;
@property (nonatomic, weak) NSTextField *txtContentsPage;
@property (nonatomic, weak) NSTextField *txtContentsPageTitle;

@property (nonatomic, weak) NSButton *goMakeProject;
@property (nonatomic, weak) NSButton *goMakeTachiyomi;
@property (nonatomic, weak) NSButton *goMakeFolder;
@property (nonatomic, weak) NSButton *goMakeEPUB;
@property (nonatomic, weak) NSButton *goMakeSplitEPUB;


@property (nonatomic, copy) NSString *eCode;
@property (nonatomic, copy) NSString *manageCode;
@property (nonatomic, copy) NSString *publishDate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *titlePron;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *authorPron;
@property (nonatomic, copy) NSString *mokujiPage;
@property (nonatomic, copy) NSString *mokujiPageTitle;
@property (nonatomic, copy) NSString *colophonPage;
@property (nonatomic, copy) NSString *tachiRange;
@property (nonatomic, copy) NSString *startPage;
@property (nonatomic, copy) NSURL *projectPath;
@property (nonatomic, assign) BOOL isLeftOpen;

// Manual Setting
@property (nonatomic, assign) BOOL isNoContents;
@property (nonatomic, copy) NSArray* theDaiwari;
@property (nonatomic, copy) NSArray* theContents;
@property (nonatomic, copy) NSArray* theSplits;
@property (nonatomic, assign) BOOL isMadePrj;
@property (nonatomic, assign) BOOL isMadeFolder;
@property (nonatomic, retain) NSString *hanW;
@property (nonatomic, retain) NSString *hanH;
@property (nonatomic, retain) NSNumber *orgWidth;
@property (nonatomic, retain) NSNumber *orgHeight;
@property (nonatomic, retain) NSNumber *splitPage;


//@property (nonatomic, copy) NSString *defaultFolder;
- (void)updateDefPath;
- (void)initIB;
- (void)appendToUI;
- (void)appendFromUI;
- (void)setProjectPathBar:(NSString*)p;

- (void)daiwariDelAll;
- (void)daiwariDelSelect;
- (void)daiwariMoveTop;
- (void)daiwariMoveBottom;
- (void)mokujiDelSelect;
- (void)mokujiDelAll;
- (void)mokujiDecide;
- (void)mokujiDecidePage;
- (void)makeProjectFolder;
- (void)makeFolder;
- (void)makeTachiyomi;
- (void)makeEPUB;
- (void)makeSplitEPUB;
- (void)checkHon;
- (void)checkSyo;
- (void)splitDelSelect;
- (void)splitDelAll;
@end
