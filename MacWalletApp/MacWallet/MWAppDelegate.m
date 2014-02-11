//
//  BAAppDelegate.m
//  MacWallet
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <BitcoinJKit/BitcoinJKit.h>
#import <Security/Security.h>
#import <Security/SecRandom.h>

#include "MWAppDelegate.h"
#include "RHKeychain.h"
#include "LaunchAtLoginController.h"
#include "RHPreferencesWindowController.h"
#include "MWPreferenceGeneralViewController.h"
#include "MWPreferenceIncomingPaymentViewController.h"
#include "MWTickerController.h"
#include "MWTransactionDetailsWindowController.h"
#include "MWTransactionMenuItem.h"
#include "PFMoveApplication.h"
#include "NSString+NSStringRandomPasswordAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "DuxScrollViewAnimation.h"
#import "MWSetPasswordPopover.h"
#import "MWEnterPasswordPopover.h"
#import "MWSendCoinsViewController.h"
#import "MWAddressDetailViewController.h"
#import "MWFundsReceivedViewController.h"
#import "MWErrorViewController.h"
#import "HIPasswordHolder.h"
#import "NSAttributedString+NSAttributedString_Colors.h"
#import "MWCreateWalletController.h"
#import "NSStatusItem+NSStatusItem_i7MultipleMenuBarSupport.h"

// this is required for embedding the unit/UI tests into the appdelegate start hook
#import "MWTestRunTests.h"

@interface MWAppDelegate ()

@property (strong) NSStatusItem * statusItem;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenu *addressesMenu;
@property (assign) IBOutlet NSMenuItem *addressesMenuItem;
@property (assign) IBOutlet NSMenu *transactionsMenu;
@property (assign) IBOutlet NSMenuItem *transactionsMenuItem;
@property (assign) IBOutlet NSMenuItem *sendCoinsMenuItem;
@property (assign) IBOutlet NSMenuItem *preferencesMenuItem;
@property (assign) IBOutlet NSMenuItem *aboutMenuItem;
@property (assign) IBOutlet NSMenuItem *quitMenuItem;
@property (assign) IBOutlet NSMenuItem *networkStatusMenuItem;
@property (assign) IBOutlet NSMenuItem *networkStatusPeersMenuItem;
@property (assign) IBOutlet NSMenuItem *networkStatusBlockHeight;
@property (assign) IBOutlet NSMenuItem *networkStatusLastBlockTime;
@property (assign) IBOutlet NSMenuItem *networkStatusNetSwitch;
@property (assign) IBOutlet NSMenuItem *networkResyncChainMenuItem;
@property (assign) IBOutlet NSMenuItem *balanceUnconfirmedMenuItem;
@property (assign) IBOutlet NSMenuItem *errorMenuItem;
@property (assign) IBOutlet NSMenuItem *createWalletMenuItem;
@property (assign) IBOutlet NSMenuItem *secondRowItem;
@property (assign) IBOutlet NSMenuItem *walletMenuItem;
@property (assign) IBOutlet NSMenuItem *walletSetPasswordMenuItem;
@property (assign) IBOutlet NSMenuItem *walletRemovePasswordMenuItem;
@property (assign) IBOutlet NSMenuItem *walletDumpMenuItem;
@property (assign) IBOutlet NSMenuItem *checkForUpdatesMenuItem;

@property (assign) BOOL useKeychain;
@property (strong) MWSendCoinsViewController *sendCoinsWindowController;
@property (strong) MWTransactionsWindowController *txWindowController;
@property (strong) MWTransactionDetailsWindowController *txDetailWindowController;
@property (strong) RHPreferencesWindowController * preferencesWindowController;
@property (strong) NSString *ticketValue;
@property (strong) NSTimer *tickerTimer;

@property (assign) uint64_t lastBalanceUnconfirmed;
@property (assign) uint64_t lastBalance;

@property (strong) IBOutlet MWSetPasswordPopover *choosePasswordPopover;
@property (strong) IBOutlet MWEnterPasswordPopover *enterPasswordPopover;

@property (strong) IBOutlet NSPopover *sendCoinsPopover;

@property (strong) NSColor *currentMenuColor;

@property (assign) NSInteger activeWallets;
@end

@implementation MWAppDelegate


#pragma mark - Application Delegate Hooks
// main entry point
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // set the default color for the attributed sting in the StatusMenuItem /HACK
    self.currentMenuColor = [NSColor blackColor];
    
    // init the ticker
    [MWTickerController defaultController].tickerFilePath = [[NSBundle mainBundle] pathForResource:@"tickers" ofType:@"plist"];
    
    // do some localization
    self.sendCoinsMenuItem.title    = NSLocalizedString(@"sendCoins", @"sendCoinsMenuItem");
    self.addressesMenuItem.title    = NSLocalizedString(@"myAddresses", @"My Address Menu Item");
    self.transactionsMenuItem.title = NSLocalizedString(@"myTransactions", @"My Transaction Menu Item");
    self.preferencesMenuItem.title  = NSLocalizedString(@"preferences", @"Preferences Menu Item");
    self.aboutMenuItem.title        = NSLocalizedString(@"about", @"About Menu Item");
    self.quitMenuItem.title         = NSLocalizedString(@"quit", @"Quit Menu Item");
    self.walletMenuItem.title       = NSLocalizedString(@"walletMenuItem", @"Wallet Menu Item");
    
    self.walletSetPasswordMenuItem.title = NSLocalizedString(@"setPassword", @"Set Password Menu Item");
    self.walletRemovePasswordMenuItem.title         = NSLocalizedString(@"removePassword", @"Remove Password Menu Item");
    self.walletDumpMenuItem.title         = NSLocalizedString(@"dumpWallet", @"Dump Wallet Menu Item");
    self.checkForUpdatesMenuItem.title    = NSLocalizedString(@"checkForUpdatesMenuItem", @"Check For Updates Menu Item");
    
    self.networkStatusLastBlockTime.title =[NSString stringWithFormat:@"%@ ?", NSLocalizedString(@"lastBlockAge", @"Last Block Age Menu Item")];
    self.networkResyncChainMenuItem.title = NSLocalizedString(@"resyncBlockchain", @"Resync the Block Chain Menu Item");
    
    
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    self.statusMenu.delegate = self;
    [self.statusItem setTitle:@""];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setAction:@selector(statusItemClicked)];
    
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon"]];
    
    
    // if first start, check if user likes that the app will run after login
    [self checkRunAtStartup];
    
    // check for migration / basic value setting
    [self checkMigrationAndDefaults];
    
    // copy the app if required to applications folder
    PFMoveToApplicationsFolderIfNecessary();
    
    
    // register for some notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAfterSettingsChanges)
                                                 name:kSHOULD_UPDATE_AFTER_PREFS_CHANGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTransactionDetailWindow:)
                                                 name:kSHOULD_SHOW_TRANSACTION_DETAILS_FOR_ID
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coinsReceived:)
                                                 name:kHIBitcoinManagerCoinsReceivedNotification
                                               object:nil];
    
    // add observers
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"connections" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"syncProgress" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"isRunning" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"peerCount" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    
    // check for testnet
    BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    [HIBitcoinManager defaultManager].testingNetwork = testnet;
    
    // define app name and support directory name
    if(testnet)
    {
        [HIBitcoinManager defaultManager].appName = @"macwallet_testnet";
    }
    else
    {
        [HIBitcoinManager defaultManager].appName = @"macwallet";
    }
    
    [HIBitcoinManager defaultManager].appSupportDirectoryIdentifier = @"MacWallet";
    
    // check if user likes to store/retrive the wallet from keychain
    // TODO: remove keychain option! Must be built into bitcoinj to make sense.
    self.useKeychain = [[NSUserDefaults standardUserDefaults] boolForKey:kUSE_KEYCHAIN_KEY];

    self.activeWallets = 0;
    
    NSError *error = nil;
    [[HIBitcoinManager defaultManager] initialize:&error];
    
    error = nil;
    [[HIBitcoinManager defaultManager] loadWallet:&error];
    
    if(error.code == kHIBitcoinManagerNoWallet)
    {
        [self createWalletMenuItemWasPressed:self];
    }
    else if(error.code == kHIBitcoinManagerUnreadableWallet)
    {
        [self showUnreableWalletError:error];
    }
    else
    {
        //TODO, add possibility of multiple wallets
        self.activeWallets = 1;
    }
    
    // update wallet related menu
    [self updateWalletMenuItem];
    
    error = nil;
    [[HIBitcoinManager defaultManager] startBlockchain:&error];
    
    // add time for periodical menu updates
    NSTimer *timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(minuteUpdater) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    // update menu with inital stuff
    [self updateNetworkMenuItem];
    
    self.tickerTimer = [NSTimer timerWithTimeInterval:kTICKET_UPDATE_INTERVAL_IN_SECONDS target:self selector:@selector(updateTicker) userInfo:nil repeats:YES];
    [self.tickerTimer fire];
    
    [[NSRunLoop mainRunLoop] addTimer:self.tickerTimer forMode:NSDefaultRunLoopMode];
    
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    for(NSString *element in arguments)
    {
        if([[element lowercaseString] isEqualToString:@"-uitest"])
        {
            MWTestRunTests *test = [[MWTestRunTests alloc] init];
            NSThread *thr = [[NSThread alloc] initWithTarget:test selector:@selector(runTests) object:nil];
            [thr start];
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[HIBitcoinManager defaultManager] saveWallet];
}

#pragma mark - Migration / Version / first Start

- (void)checkRunAtStartup
{
    // Get current version ("Bundle Version") from the default Info.plist file
    NSString *currentVersion = (NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSArray *prevStartupVersions = [[NSUserDefaults standardUserDefaults] arrayForKey:kPREV_VERSIONS_STARTED_KEY];
    if (prevStartupVersions == nil)
    {
        
        // Save changes to disk
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK Button")];
        [alert addButtonWithTitle:NSLocalizedString(@"No", @"No Button")];
        [alert setMessageText:NSLocalizedString(@"launchAtStartupQuestion", @"launch at startup question")];
        [alert setInformativeText:@""];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger alertResult = [alert runModal];
        if(alertResult == NSAlertFirstButtonReturn) {
            self.launchAtStartup = YES;
        }
        else {
            self.launchAtStartup = NO;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:currentVersion] forKey:kPREV_VERSIONS_STARTED_KEY];
    }
    else
    {
        if (![prevStartupVersions containsObject:currentVersion])
        {
            // add the current version to the startup version array
            NSMutableArray *updatedPrevStartVersions = [NSMutableArray arrayWithArray:prevStartupVersions];
            [updatedPrevStartVersions addObject:currentVersion];
            [[NSUserDefaults standardUserDefaults] setObject:updatedPrevStartVersions forKey:kPREV_VERSIONS_STARTED_KEY];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkMigrationAndDefaults
{
    NSString *bundleVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    NSString *appFirstStartOfVersionKey = [NSString stringWithFormat:@"first_start_%@", bundleVersion];
    NSString *appFirstStartOfVersionKeyV2 = @"first_start_2"; // version 2
    
    NSNumber *alreadyStartedOnVersion = [[NSUserDefaults standardUserDefaults] objectForKey:appFirstStartOfVersionKey];
    NSNumber *alreadyStartedOnVersionV2 = [[NSUserDefaults standardUserDefaults] objectForKey:appFirstStartOfVersionKeyV2];
    
    if(!alreadyStartedOnVersionV2 || [alreadyStartedOnVersionV2 boolValue] == NO) {
        
        // version 2 never started
        [[NSUserDefaults standardUserDefaults] setInteger:MWStatusItemStyleBoth forKey:kSTATUS_ITEM_STYLE_KEY];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSHOW_NOTIFICATION_INCOMING_FUNDS];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:appFirstStartOfVersionKey];
    }
    if(!alreadyStartedOnVersion || [alreadyStartedOnVersion boolValue] == NO) {
        
        // current version never started
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - NSMenuDelegate

- (void) menuWillOpen:(NSMenu *) aMenu {
    self.currentMenuColor = [NSColor whiteColor];
    [self changeAttributedStringColor];
    
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon_inverted"]];
}


- (void) menuDidClose:(NSMenu *) aMenu {
    self.currentMenuColor = [NSColor blackColor];
    [self changeAttributedStringColor];
    
    [self.statusItem setImage:[NSImage imageNamed:@"status_bar_icon"]];
}

- (void)changeAttributedStringColor
{
    NSMutableAttributedString *titleString = [self.statusItem.attributedTitle mutableCopy];
    NSRange range= NSMakeRange(0,titleString.string.length);
    [titleString addAttribute:NSForegroundColorAttributeName value:self.currentMenuColor range:range];
    self.statusItem.attributedTitle = titleString;
}

#pragma mark - HIBitcoinJKit Observers

// observe the bitcoin framework
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [HIBitcoinManager defaultManager])
    {
        if ([keyPath compare:@"balance"] == NSOrderedSame)
        {
            // balance has changed
            [self updateStatusMenu];
            
            
            if ([HIBitcoinManager defaultManager].isRunning)
            {
                [self rebuildTransactionsMenu];
            }
        }
        else if ([keyPath compare:@"isRunning"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].isRunning)
            {
                [self updateMyAddresses:[HIBitcoinManager defaultManager].allWalletAddresses];
                [self updateStatusMenu];
            }
            else {
                self.networkStatusMenuItem.title = NSLocalizedString(@"syncingIsOff", @"SyncingIsOff Menu Item");
            }
        }
        else if ([keyPath compare:@"syncProgress"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].syncProgress < 1.0)
            {
                if ([HIBitcoinManager defaultManager].isRunning)
                {
                    // we are syncing
                    self.networkStatusMenuItem.title =[NSString stringWithFormat:@"%@ %d%%",NSLocalizedString(@"syncing", @"Syncing Menu Item"), (int)round((double)[HIBitcoinManager defaultManager].syncProgress*100)];
                }
            }
            else {
                // sync finished
                self.networkStatusMenuItem.title = NSLocalizedString(@"Network: synced", @"Network Menu Item Synced");
                
                [self minuteUpdater];
                [self updateStatusMenu];
                [self rebuildTransactionsMenu];
            }

            // always update the block info
            self.networkStatusBlockHeight.title = [NSString stringWithFormat:@"%@%ld/%ld",NSLocalizedString(@"blocksMenuItem", @"Block Menu Item"),[HIBitcoinManager defaultManager].currentBlockCount, [HIBitcoinManager defaultManager].totalBlocks];
            
        }
        else if ([keyPath compare:@"peerCount"] == NSOrderedSame)
        {
            // peer connected/disconnected
            self.networkStatusPeersMenuItem.title = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"connectedPeersMenuItem", @"connectedPeersMenuItem"), (unsigned long)[HIBitcoinManager defaultManager].peerCount];
        }
    }
}

- (void)minuteUpdater
{
    NSDate *date = [HIBitcoinManager defaultManager].lastBlockCreationTime;
    if(date)
    {
        NSTimeInterval lastAge = -[date timeIntervalSinceNow]/60;
        if(lastAge >= 100)
        {
            self.networkStatusLastBlockTime.title =[NSString stringWithFormat:@"%@ %.1f h", NSLocalizedString(@"lastBlockAge", @"Last Block Age Menu Item"), -[date timeIntervalSinceNow]/3600];
        }
        else {
            self.networkStatusLastBlockTime.title =[NSString stringWithFormat:@"%@ %.1f min", NSLocalizedString(@"lastBlockAge", @"Last Block Age Menu Item"), -[date timeIntervalSinceNow]/60];
        }
        
    }
    [self rebuildTransactionsMenu];
}

- (void)updateAfterSettingsChanges
{
    [self updateStatusMenu];
    [self rebuildTransactionsMenu];
    [self.tickerTimer fire];
}



#pragma mark - menu actions / menu stack
- (void)updateStatusMenu
{
    [self updateStatusMenu:NO];
}
- (void)updateStatusMenu:(BOOL)tickerOnly
{
    
    if(tickerOnly == NO)
    {
        self.lastBalanceUnconfirmed = [HIBitcoinManager defaultManager].balanceUnconfirmed;
        self.lastBalance = [HIBitcoinManager defaultManager].balance;
    }
    
    uint64_t fundsOnTheWay = self.lastBalanceUnconfirmed-self.lastBalance;
    
    if(fundsOnTheWay > 0)
    {
        [self.balanceUnconfirmedMenuItem setHidden:NO];
    }
    else {
        [self.balanceUnconfirmedMenuItem setHidden:YES];
    }
    
    NSFont *font = [NSFont systemFontOfSize:10];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Funds on the way:\n%@",@"Funds on the way menu item"), [[HIBitcoinManager defaultManager] formatNanobtc:fundsOnTheWay]] attributes:attrsDictionary];
    
    NSInteger statusItemStyle = [[NSUserDefaults standardUserDefaults] integerForKey:kSTATUS_ITEM_STYLE_KEY];
    
    if(statusItemStyle == MWStatusItemStyleBoth)
    {
        // set a two line status item
        [self.secondRowItem setHidden:YES];
        
        // make sure, ticker is not displaying "(null)"
        NSString *tickerValue = self.ticketValue;
        if(!tickerValue)
        {
            tickerValue = NSLocalizedString(@"loadingTickerShort", @"loaing text when in status menu when ticker is not ready");
        }
        NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSRightTextAlignment];
        [paragraphStyle setMaximumLineHeight:9];
        [paragraphStyle setHeadIndent:0];
        
        NSFont *font2 = [NSFont boldSystemFontOfSize:9];
        NSDictionary *attrsDictionary2 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font2, [NSColor blackColor], paragraphStyle, nil]
                                                                     forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, nil] ];
        NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n%@",tickerValue, [[HIBitcoinManager defaultManager] formatNanobtc:self.lastBalance withDesignator:YES]] attributes:attrsDictionary2];
        
        NSMutableParagraphStyle *paragraphStyle2 =[[NSMutableParagraphStyle alloc] init];
        [paragraphStyle2 setAlignment:NSRightTextAlignment];
        [paragraphStyle2 setMaximumLineHeight:1];
        [paragraphStyle2 setHeadIndent:0];
        
        NSRange range = NSMakeRange(0,1);
        
        [text addAttribute:NSParagraphStyleAttributeName
                                   value:paragraphStyle2
                                   range:range];
        
        self.statusItem.attributedTitle = text;
        [self changeAttributedStringColor];
    }
    else if(statusItemStyle == MWStatusItemStyleTicker)
    {
        self.statusItem.title = self.ticketValue;
        [self.secondRowItem setHidden:NO];
        
        // 2nd row is the wallet balance
        self.secondRowItem.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"secondLineBalanceLabel", @""), [[HIBitcoinManager defaultManager] formatNanobtc:self.lastBalance]];
    }
    else
    {
        
        self.statusItem.title = [[HIBitcoinManager defaultManager] formatNanobtc:self.lastBalance];
        
        // 2nd row is the ticker
        if(self.ticketValue.length > 0)
        {
            [self.secondRowItem setHidden:NO];
            
            NSString *optimizedString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"secondLineTickerLabel", @""),self.ticketValue];
            
            NSString *tickerName = [[NSUserDefaults standardUserDefaults] objectForKey:kTICKER_NAME_KEY];
            if(!tickerName || tickerName.length == 0)
            {
                tickerName = kDEFAULT_TICKER_NAME;
            }
            if(!tickerName || tickerName.length <= 0)
            {
                [self.secondRowItem setHidden:YES];
            }
            else
            {
                optimizedString = [optimizedString stringByReplacingOccurrencesOfString:@"@$1" withString:tickerName];
                self.secondRowItem.title = optimizedString;
            }
        }
        else {
            [self.secondRowItem setHidden:YES];
        }
    }
    
    self.balanceUnconfirmedMenuItem.attributedTitle = string;
    
    if(tickerOnly == NO)
    {
        [self rebuildTransactionsMenu];
    }
}

// switch the network
- (IBAction)testnetSwitchChecked:(NSMenuItem *)sender
{
    BOOL testnetOn = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK Button")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"OK Button")];
    if(!testnetOn)
    {
        [alert setMessageText:NSLocalizedString(@"switchToTestnet", @"switch to testnet alert")];
    }
    else
    {
        [alert setMessageText:NSLocalizedString(@"Would you like to switch to the Standard Bitcoin Network?", @"switch to prodnet alert")];
    }
    [alert setInformativeText:@""];
    [alert setAlertStyle:NSWarningAlertStyle];
    NSInteger alertResult = [alert runModal];
    if(alertResult == NSAlertFirstButtonReturn) {
        [[NSUserDefaults standardUserDefaults] setBool:!testnetOn forKey:kTESTNET_SWITCH_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self updateNetworkMenuItem];
        
        
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK Button")];
        [alert setMessageText:NSLocalizedString(@"restartAppText", @"alert text which requests a restart")];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    else {
        
    }
}

- (void)updateNetworkMenuItem
{
    BOOL testnetOn = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    if(testnetOn)
    {
        self.networkStatusNetSwitch.title = NSLocalizedString(@"Network: Testnet", @"Testnet on state Menu Item");
    }
    else
    {
        self.networkStatusNetSwitch.title = NSLocalizedString(@"Network: Bitcoin", @"Testnet on state Menu Item");
    }
}

- (IBAction)errorMenuItemWasPressed:(id)sender {
    
}

- (IBAction)createWalletMenuItemWasPressed:(id)sender
{
    NSPopover *popover = [[NSPopover alloc] init];
    MWCreateWalletController *vc = [[MWCreateWalletController alloc]
                                        initWithNibName:@"MWCreateWalletController" bundle:nil];
    vc.popover = popover;
    vc.delegate = self;
    popover.contentViewController = vc;
    
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    [popover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    
}

- (void)showErrorText:(NSString *)aText
{
    [self.errorMenuItem setAttributedTitle:[NSAttributedString attributedStringWithString:aText fontSize:10 color:[NSColor redColor]]];
    [self.errorMenuItem setHidden:NO];
}

- (void)hideError
{
    [self.errorMenuItem setTitle:@""];
    [self.errorMenuItem setHidden:YES];
}

#pragma mark - createWallet delegate stack

- (void)walletController:(MWCreateWalletController *)walletController wantsToCreateWalletWithPassword:(HIPasswordHolder *)passwordHolder
{
    NSError *error = nil;
    @try {
        [[HIBitcoinManager defaultManager] createWalletWithPassword:passwordHolder.data error:&error];
    }
    @finally {
        [passwordHolder clear];
    }
    
    if(!error)
    {
        //TODO, add possibility of multiple wallets
        self.activeWallets = 1;
        
        // update wallet related menu
        [self updateWalletMenuItem];
    }
    //TODO: error handling
}

#pragma mark - wallet/address stack
- (void)updateWalletMenuItem
{
    if(self.activeWallets == 0)
    {
        [self.walletMenuItem setHidden:YES];
        [self.transactionsMenuItem setHidden:YES];
        [self.addressesMenuItem setHidden:YES];
        [self.sendCoinsMenuItem setHidden:YES];
        
        [self showErrorText:NSLocalizedString(@"NoWalletPresent", @"No Wallet Present Menu Label")];
        [self.createWalletMenuItem setHidden:NO];
        
        return;
    }
    else
    {
        [self.walletMenuItem setHidden:NO];
        [self.transactionsMenuItem setHidden:NO];
        [self.addressesMenuItem setHidden:NO];
        [self.sendCoinsMenuItem setHidden:NO];
        
        [self hideError];
        [self.createWalletMenuItem setHidden:YES];
    }
    if([[HIBitcoinManager defaultManager] isWalletEncrypted])
    {
        [self.walletMenuItem setImage:[NSImage imageNamed:@"secure"]];
        
        [self.walletSetPasswordMenuItem setEnabled:NO];
        [self.walletRemovePasswordMenuItem setEnabled:YES];
    }
    else {
        [self.walletMenuItem setImage:[NSImage imageNamed:@"not-secure"]];
        
        [self.walletSetPasswordMenuItem setEnabled:YES];
        [self.walletRemovePasswordMenuItem setEnabled:NO];
    }
}

- (void)updateMyAddresses:(NSArray *)addresses
{
    NSLog(@"%@", addresses);
    [self.addressesMenu removeAllItems];
    
    NSFont *font = [NSFont systemFontOfSize:10];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
    
    
    for(NSString *address in addresses)
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:address action:@selector(addressClicked:) keyEquivalent:@""];
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:menuItem.title attributes:attrsDictionary];
        menuItem.attributedTitle = string;
        
        [self.addressesMenu addItem:menuItem];
    }
    
    // add seperator and a "add address" menu item
    [self.addressesMenu addItem:[NSMenuItem separatorItem]];
    [self.addressesMenu addItemWithTitle:NSLocalizedString(@"addAddress", @"Add Address Menu Item") action:@selector(addWalletAddress:) keyEquivalent:@""];
}

- (void)addressClicked:(NSMenuItem *)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:sender.title forType:NSStringPboardType];
    
    [self showDetailsForAddress:sender.title];
}

- (void)addWalletAddress:(id)sender
{
    [[HIBitcoinManager defaultManager] addKey];
    [self updateMyAddresses:[HIBitcoinManager defaultManager].allWalletAddresses];
}

- (IBAction)resyncBlockchain:(id)sender
{
    NSError *error = nil;
    [[HIBitcoinManager defaultManager] resyncBlockchain:&error];
}

- (void)coinsReceived:(NSNotification *)notification
{
    NSString *tx = notification.object;
    NSDictionary *transactionDict = [[HIBitcoinManager defaultManager] transactionForHash:tx];
    nanobtc_t amount = [[transactionDict objectForKey:@"amount"] longLongValue];
    NSString *funds = [[HIBitcoinManager defaultManager] formatNanobtc:amount withDesignator:YES];
    
    NSString *text = [NSString stringWithFormat:NSLocalizedString(@"newFundsOnTheWayText", @"new funds on the way user notification text"), funds];
    
    [self doReceivedCoinsAction:text amount:funds txID:tx];
}

- (void)demoCoinsAction
{
    NSString *amount = [[HIBitcoinManager defaultManager] formatNanobtc:1000002345];
    NSString *aText = [NSString stringWithFormat:NSLocalizedString(@"newFundsOnTheWayText", @"new funds on the way user notification text"), amount];
    
    [self doReceivedCoinsAction:aText amount:amount txID:@"9152e20b1b0b0a2939936287f3a814e1befc3a34c1be5415f52b1df372d262f6"];
}

- (void)doReceivedCoinsAction:(NSString *)text amount:(NSString *)amout txID:(NSString *)txId
{
    BOOL showNotification = [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_NOTIFICATION_INCOMING_FUNDS];
    BOOL showPopup = [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_POPUP_INCOMING_FUNDS];
    BOOL playSound = [[NSUserDefaults standardUserDefaults] boolForKey:kPLAY_SOUND_INCOMING_FUNDS];
    NSString *playSoundPath = [[NSUserDefaults standardUserDefaults] objectForKey:kPLAY_SOUND_PATH_INCOMING_FUNDS];
    
    BOOL runScript = [[NSUserDefaults standardUserDefaults] boolForKey:kRUN_SCRIPT_INCOMING_FUNDS];
    NSString *runScriptPath = [[NSUserDefaults standardUserDefaults] objectForKey:kRUN_SCRIPT_PATH_INCOMING_FUNDS];
    
    if([NSUserNotification class] && [NSUserNotificationCenter class] && showNotification)
    {
        NSUserNotification *userNotification = [[NSUserNotification alloc] init];
        [userNotification setTitle:NSLocalizedString(@"newFundsOnTheWayTitle", @"new funds on the way user notification title")];
        [userNotification setInformativeText:text];
        
        [userNotification setDeliveryDate:[NSDate dateWithTimeInterval:0 sinceDate:[NSDate date]]];
        [userNotification setSoundName:NSUserNotificationDefaultSoundName];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center scheduleNotification:userNotification];
    }
    if(showPopup)
    {
        NSPopover *popover = [[NSPopover alloc] init];
        MWFundsReceivedViewController *vc = [[MWFundsReceivedViewController alloc] initWithNibName:@"MWFundsReceivedViewController" bundle:nil];
        vc.popover = popover;
        vc.textToShow = text;
        popover.contentViewController = vc;
        
        NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
        NSRect frame = appWin.frame;
        NSView *view = appWin.contentView;
        [popover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    }
    if(playSound)
    {
        NSSound *sound = [[NSSound alloc] initWithContentsOfFile:playSoundPath byReference:YES];
        if(sound)
        {
            [sound play];
        }
        else
        {
            sound = [NSSound soundNamed:@"Glass"];
        }
        
        [sound play];
    }
    if(runScript)
    {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:runScriptPath];
        [task setArguments:[NSArray arrayWithObjects:txId, nil]];
        [task setStandardOutput:[NSPipe pipe]];
        [task setStandardInput:[NSPipe pipe]];
        
        [task launch];
    }
}

- (IBAction)dumpWallet:(id)sender
{
    if([[HIBitcoinManager defaultManager] isWalletEncrypted])
    {
        NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
        NSRect frame = appWin.frame;
        NSView *view = appWin.contentView;
        
        [self.enterPasswordPopover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
        
        self.enterPasswordPopover.okaySelector = @selector(dumpWalletWithPassphrase:);
        self.enterPasswordPopover.okayTarget = self;
        
    }
    else
    {
        [self dumpWalletWithPassphrase:nil];
    }

}

- (void)dumpWalletWithPassphrase:(NSString *)passphrase
{
    // remove the delegate so it's save to remove object from memory
    self.enterPasswordPopover.okaySelector = nil;
    self.enterPasswordPopover.okayTarget = nil;
    
    // close the popup
    [self.enterPasswordPopover performClose:self];
    
    // ask where to dump the wallet
    NSInteger result;
    NSSavePanel *sPanel = [NSSavePanel savePanel];
    sPanel.title = NSLocalizedString(@"dumpWalletToTitle", @"Dump Wallet Title for Save Panel");
    [sPanel setNameFieldStringValue:NSLocalizedString(@"recommendedFilenameForWalletDump", @"Recommended Filename for a dumped wallet")];
    
    [sPanel setCanCreateDirectories:YES];
    
    
    result = [sPanel runModal];
    if (result == NSOKButton) {
        
        // dump now
        BOOL success = [[HIBitcoinManager defaultManager] exportWalletWithPassphase:passphrase To:sPanel.URL];
        
        if(!success)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"errorDumpWallet",@"Alert Message When Dump Was NOK")];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:NSLocalizedString(@"successDumpWallet",@"Success Message When Dump Was Okay")];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert runModal];
        }
    }
}

- (void)showUnreableWalletError:(NSError *)error
{
    
    NSPopover *popover = [[NSPopover alloc] init];
    MWErrorViewController *vc = [[MWErrorViewController alloc] initWithNibName:@"MWErrorViewController" bundle:nil];
    vc.popover = popover;
    vc.textToShow = NSLocalizedString(@"unreadbleWalletError", @"");
    popover.contentViewController = vc;
    
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    [popover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    
    self.activeWallets = 0;
    
    [self showErrorText:NSLocalizedString(@"unreadbleWalletError", @"Error Text when wallet file is unreadable")];

    [self.sendCoinsMenuItem setHidden:YES];
}


// market for deletion
//////////////////////
//
///*
// * saves a passphrase to the osx keychain
// *
// */
//- (void)setWalletBasicEncryptionPassphrase:(NSString *)baseKey
//{
//    BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
//    NSString *keychainServiceName = (testnet) ? kKEYCHAIN_SERVICE_NAME_TESTNET : kKEYCHAIN_SERVICE_NAME;
//    
//    if(!baseKey || baseKey.length == 0)
//    {
//        return;
//    }
//    
//    if(!RHKeychainDoesGenericEntryExist(NULL, keychainServiceName))
//    {
//        RHKeychainAddGenericEntry(NULL, keychainServiceName);
//        RHKeychainSetGenericComment(NULL, keychainServiceName, @"MacWallet wallet encryption passphrase");
//    }
//    
//    RHKeychainSetGenericPassword(NULL, keychainServiceName, baseKey);
//}
//
//- (NSString *)walletBasicEncryptionPassphrase
//{
//    BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
//    NSString *keychainServiceName = (testnet) ? kKEYCHAIN_SERVICE_NAME_TESTNET : kKEYCHAIN_SERVICE_NAME;
//    
//    if(RHKeychainDoesGenericEntryExist(NULL, keychainServiceName))
//    {
//        return RHKeychainGetGenericPassword(NULL, keychainServiceName);
//    }
//    else
//    {
//        return nil;
//    }
//}

#pragma mark - wallet encryption stack

// opens the encrypt wallet view
- (IBAction)encryptWallet:(id)sender
{
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    
    [self.choosePasswordPopover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    
    
    [appWin selectNextKeyView:self];
}

// opens the remove wallet encryption view
- (IBAction)removeWalletEncryption:(id)sender {
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    
    [self.enterPasswordPopover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
}

// decrypts the wallet with a passphrase
- (BOOL)shouldPerformRemoveEncryption:(HIPasswordHolder *)passwordHolder
{
    NSError *error = nil;
    @try {
        [[HIBitcoinManager defaultManager] removeEncryption:passwordHolder.data error:&error];
    }
    @finally {
        [passwordHolder clear];
    }
    [self updateWalletMenuItem];
    
    if(!error)
    {
        return YES;
    }
    
    return NO;
}

// encrypts the wallet with a passphrase
- (void)shouldPerformEncryption:(HIPasswordHolder *)passwordHolder
{
    NSError *error = nil;
    @try {
        [[HIBitcoinManager defaultManager] changeWalletPassword:[NSData data] toPassword:passwordHolder.data error:&error];
    }
    @finally {
        [passwordHolder clear];
    }
    [self updateWalletMenuItem];
}


#pragma mark - transactions stack

- (void)rebuildTransactionsMenu
{
    // get amount of transaction
    NSUInteger totalTransactionCount =  [[HIBitcoinManager defaultManager] transactionCount];
    
    
    // remove all menu items and recreate the transaction menu
    // TODO: make kDEFAULT_MAX_TRANSACTION_COUNT_MENU configurable throught settings
    [self.transactionsMenu removeAllItems];
    NSArray *displayTransactions =  [[HIBitcoinManager defaultManager] allTransactions:kDEFAULT_MAX_TRANSACTION_COUNT_MENU];
    
    // set font for transaction label
    NSFont *font = [NSFont systemFontOfSize:14];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
    NSUInteger hiddenTransactions = MAX(totalTransactionCount - displayTransactions.count, 0);
    for(NSDictionary *transactionDict in displayTransactions)
    {
        
        nanobtc_t amount = [[transactionDict objectForKey:@"amount"] longLongValue];
        NSDate *time = [transactionDict objectForKey:@"time"];
        NSTimeInterval ageInSeconds = -[time timeIntervalSinceNow];
        NSString *age = nil;
        
        if(ageInSeconds > 60*60*24)
        {
            age = [NSString stringWithFormat:@"%.1f d", ageInSeconds/60/60/24];
        }
        else if(ageInSeconds > 60*60)
        {
            age = [NSString stringWithFormat:@"%.1f h", ageInSeconds/60/60];
        }
        else {
            age = [NSString stringWithFormat:@"%.1f min", ageInSeconds/60];
        }
        
        NSString *format = @"%@";
        if([[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_TIME_AGO_KEY] == YES)
        {
            format = [format stringByAppendingString:NSLocalizedString(@"timeAgoFormat", @"")];
        }
        
        MWTransactionMenuItem *menuItem = [[MWTransactionMenuItem alloc] initWithTitle:[NSString stringWithFormat:format, [[HIBitcoinManager defaultManager] formatNanobtc:amount withDesignator:YES], age ] action:@selector(transactionClicked:) keyEquivalent:@""];
        menuItem.txId = [transactionDict objectForKey:@"txid"];
        
        if([[transactionDict objectForKey:@"confidence"] isEqualToString:@"building"])
        {
            [menuItem setImage:[NSImage imageNamed:@"TrustedCheckmark"]];
        }
        else
        {
            [menuItem setImage:[NSImage imageNamed:@"Questionmark"]];
        }
        
        NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:menuItem.title attributes:attrsDictionary];
        if(amount < 0)
        {
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0,string.length)];
        }
        else {
            [string addAttribute:NSForegroundColorAttributeName value:[NSColor blackColor] range:NSMakeRange(0,string.length)];
        }
        [menuItem setAttributedTitle:string];
        
        
        [self.transactionsMenu addItem:menuItem];
    }
    if(displayTransactions.count == 0)
    {
        [self.transactionsMenu addItemWithTitle:NSLocalizedString(@"noTransactionsFound", @"No Transactions Found Menu Item") action:nil keyEquivalent:@""];
    }
    else if(hiddenTransactions > 0)
    {
        [self.transactionsMenu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"moreTx", @"more transaction menu item"), hiddenTransactions] action:nil keyEquivalent:@""];
    }
    // add a separator as well as a "show all transaction" menu item
    [self.transactionsMenu addItem:[NSMenuItem separatorItem]];
    
    [self.transactionsMenu addItemWithTitle:NSLocalizedString(@"showAllTransaction", @"Show All Transaction Menu Item") action:@selector(showTransactionWindow:) keyEquivalent:@""];
}
    
- (void)transactionClicked:(id)sender
{
    MWTransactionMenuItem *txMenuItem = (MWTransactionMenuItem *)sender;
    NSString *txHash = txMenuItem.txId;
    NSDictionary *dict = [[HIBitcoinManager defaultManager] transactionForHash:txHash];
    [self showTransactionDetailWindow:dict];
}

- (IBAction)showTransactionWindow:(id)sender
{
    self.txWindowController = [[MWTransactionsWindowController alloc] initWithWindowNibName:@"MWTransactionsWindowController"];
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.txWindowController showWindow:nil];
    [self.txWindowController.window orderFrontRegardless];
}

- (IBAction)showTransactionDetailWindow:(NSDictionary *)txDict
{
    if([txDict isKindOfClass:[NSNotification class]])
    {
        // it's a notification
        txDict = [(NSNotification *)txDict object];
    }
    if([txDict isKindOfClass:[NSString class]])
    {
        // get txdict if parameter 0 is only a string (txid)
        txDict = [[HIBitcoinManager defaultManager] transactionForHash:(NSString *)txDict];
    }
    self.txDetailWindowController = [[MWTransactionDetailsWindowController alloc] initWithWindowNibName:@"MWTransactionDetailsWindowController"];
    
    self.txDetailWindowController.txDict = txDict;
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.txDetailWindowController showWindow:nil];
    [self.txDetailWindowController.window orderFrontRegardless];
}

#pragma mark - send coins stack
- (IBAction)openSendCoins:(id)sender
{
    if(self.activeWallets == 0)
    {
        return;
    }
    
    NSPopover *popover = [[NSPopover alloc] init];
    self.sendCoinsWindowController = [[MWSendCoinsViewController alloc] initWithNibName:@"SendCoinsWindow" bundle:nil];
    self.sendCoinsWindowController.delegate = self;
    self.sendCoinsWindowController.popover = popover;
    popover.contentViewController = self.sendCoinsWindowController;
    
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    [popover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    
    return;
}

#pragma MWSendCoinsViewController Delegate
- (nanobtc_t)prepareSendCoinsFromWindowController:(MWSendCoinsViewController *)windowController receiver:(NSString *)btcAddress amount:(nanobtc_t)amountInSatoshis txfee:(nanobtc_t)txFeeInSatoshis password:(NSData *)passwordData error:(NSError **)error
{
    nanobtc_t expectedFee = 0;
    
    [[HIBitcoinManager defaultManager] prepareSendCoins:amountInSatoshis toReceipent:btcAddress comment:@"" password:passwordData returnFee:&expectedFee error:error];
    
    return expectedFee;
}


#pragma mark - Preferences stack
- (IBAction)showPreferences:(id)sender
{
    MWPreferenceGeneralViewController *generalPrefs = [[MWPreferenceGeneralViewController alloc] initWithNibName:@"MWPreferenceGeneralViewController" bundle:nil];
    MWPreferenceIncomingPaymentViewController *walletPrefs = [[MWPreferenceIncomingPaymentViewController alloc] initWithNibName:@"MWPreferenceIncomingPaymentViewController" bundle:nil];
    
    NSArray *controllers = [NSArray arrayWithObjects:generalPrefs,walletPrefs,
                            nil];
    
    self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:controllers andTitle:NSLocalizedString(@"Preferences", @"Preferences Window Title")];
    [self.preferencesWindowController showWindow:self];
    [self.preferencesWindowController.window orderFrontRegardless];
}


#pragma mark - auto launch controlling stack

- (BOOL)launchAtStartup
{
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL state = [launchController launchAtLogin];
    launchController = nil;
    return state;
}

- (void)setLaunchAtStartup:(BOOL)aState
{
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    [launchController setLaunchAtLogin:aState];
    launchController = nil;
}

#pragma mark - ticker stack

- (void)updateTicker
{
    NSString *tickerName = [[NSUserDefaults standardUserDefaults] objectForKey:kTICKER_NAME_KEY];
    if(!tickerName || tickerName.length == 0)
    {
        tickerName = kDEFAULT_TICKER_NAME;
    }
    [[MWTickerController defaultController] loadTicketWithName:tickerName completionHandler:^(NSString *valueString, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
        self.ticketValue = valueString;
            [self updateStatusMenu:YES];
        });
    }];
}

#pragma mark - QRCode Stack
- (void)showDetailsForAddress:(NSString *)address
{
    // send notification to close already open popups
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHOULD_CLOSE_OPEN_POPUPS_NOTIFICATION object:self];
    
    NSPopover *popover = [[NSPopover alloc] init];
    MWAddressDetailViewController *vc = [[MWAddressDetailViewController alloc] initWithNibName:@"MWAddressDetailViewController" bundle:nil];
    vc.popover = popover;
    vc.addressToShow = address;
    popover.contentViewController = vc;
    
    NSWindow *appWin = [self.statusItem statusMenuItemWindowOnMainScreen];
    NSRect frame = appWin.frame;
    NSView *view = appWin.contentView;
    [popover showRelativeToRect:CGRectMake(0,0,frame.size.width,frame.size.height) ofView:view preferredEdge:NSMinYEdge];
    
    return;
}

@end
