//
//  BAAppDelegate.m
//  MacWallet
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <BitcoinJKit/BitcoinJKit.h>

#include "MWAppDelegate.h"
#include "RHKeychain.h"
#include "LaunchAtLoginController.h"
#include "RHPreferencesWindowController.h"
#include "MWPreferenceGeneralViewController.h"
#include "MWPreferenceWalletViewController.h"
#include "MWTickerController.h"
#include "MWTransactionDetailsWindowController.h"
#include "MWTransactionMenuItem.h"

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
@property (assign) IBOutlet NSMenuItem *balanceUnconfirmedMenuItem;
@property (assign) IBOutlet NSMenuItem *secondRowItem;
@property (assign) BOOL useKeychain;
@property (strong) MWSendCoinsWindowController *sendCoinsWindowController;
@property (strong) MWTransactionsWindowController *txWindowController;
@property (strong) MWTransactionDetailsWindowController *txDetailWindowController;
@property (strong) RHPreferencesWindowController * preferencesWindowController;
@property (strong) NSString *ticketValue;
@property (strong) NSTimer *tickerTimer;


@end

@implementation MWAppDelegate


// main entry point
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    // init the ticker
    [MWTickerController defaultController].tickerFilePath = [[NSBundle mainBundle] pathForResource:@"tickers" ofType:@"plist"];
    
    // do some localization
    self.sendCoinsMenuItem.title    = NSLocalizedString(@"sendCoins", @"sendCoinsMenuItem");
    self.addressesMenuItem.title    = NSLocalizedString(@"myAddresses", @"My Address Menu Item");
    self.transactionsMenuItem.title = NSLocalizedString(@"myTransactions", @"My Transaction Menu Item");
    self.preferencesMenuItem.title  = NSLocalizedString(@"preferences", @"Preferences Menu Item");
    self.aboutMenuItem.title        = NSLocalizedString(@"about", @"About Menu Item");
    self.quitMenuItem.title         = NSLocalizedString(@"quit", @"Quit Menu Item");
    self.networkStatusLastBlockTime.title =[NSString stringWithFormat:@"%@ ?", NSLocalizedString(@"lastBlockAge", @"Last Block Age Menu Item")];
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"loading..."];
    [self.statusItem setHighlightMode:YES];
    
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
    self.useKeychain = [[NSUserDefaults standardUserDefaults] boolForKey:kUSE_KEYCHAIN_KEY];
    
    // start underlaying bitcoin system
    NSString *walletBase64String = nil;
    if(self.useKeychain)
    {
        walletBase64String = [self loadWallet];
        if(walletBase64String == nil)
        {
            walletBase64String = @"";
        }
    }
    [[HIBitcoinManager defaultManager] start:walletBase64String];
    
    // add time for periodical menu updates
    NSTimer *timer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(minuteUpdater) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    // update menu with inital stuff
    [self updateNetworkMenuItem];
    
    self.tickerTimer = [NSTimer timerWithTimeInterval:kTICKET_UPDATE_INTERVAL_IN_SECONDS target:self selector:@selector(updateTicker) userInfo:nil repeats:YES];
    [self.tickerTimer fire];
    
    [[NSRunLoop mainRunLoop] addTimer:self.tickerTimer forMode:NSDefaultRunLoopMode];
    
    // register for some notifications
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAfterSettingsChanges)
                                                 name:kSHOULD_UPDATE_AFTER_PREFS_CHANGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showTransactionDetailWindow:)
                                                 name:kSHOULD_SHOW_TRANSACTION_DETAILS_FOR_ID
                                               object:nil];
    
    
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    // perform a wallet save during termination
    [self saveWallet];
}

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
            
            [self saveWallet];
        }
        else if ([keyPath compare:@"isRunning"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].isRunning)
            {
                [self updateMyAddresses:[HIBitcoinManager defaultManager].allWalletAddresses];
                [self updateStatusMenu];
            }
            else {
                //TODO switch off something
            }
        }
        else if ([keyPath compare:@"syncProgress"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].syncProgress < 1.0)
            {
                // we are syncing
                self.networkStatusMenuItem.title =[NSString stringWithFormat:@"%@ %d%%",NSLocalizedString(@"syncing", @"Syncing Menu Item"), (int)round((double)[HIBitcoinManager defaultManager].syncProgress*100)];
            }
            else {
                // sync finished
                self.networkStatusMenuItem.title = NSLocalizedString(@"Network: synced", @"Network Menu Item Synced");
                
                [self minuteUpdater];
                [self updateStatusMenu];
                [self saveWallet];
            }

            // always update the block info
            self.networkStatusBlockHeight.title = [NSString stringWithFormat:@"%@%ld/%ld",NSLocalizedString(@"blocksMenuItem", @"Block Menu Item"),[HIBitcoinManager defaultManager].currentBlockCount, [HIBitcoinManager defaultManager].totalBlocks];
            
        }
        else if ([keyPath compare:@"peerCount"] == NSOrderedSame)
        {
            // peer connected/disconnected
            self.networkStatusPeersMenuItem.title = [NSString stringWithFormat:@"%@%lu", NSLocalizedString(@"connectedPeersMenuItem", @"connectedPeersMenuItem"), (unsigned long)[HIBitcoinManager defaultManager].peerCount];
        }
    }
}

- (void)minuteUpdater
{
    NSDate *date = [HIBitcoinManager defaultManager].lastBlockCreationTime;
    if(date)
    {
        self.networkStatusLastBlockTime.title =[NSString stringWithFormat:@"%@%.1f min", NSLocalizedString(@"lastBlockAge", @"Last Block Age Menu Item"), -[date timeIntervalSinceNow]/60];
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
    uint64_t balance_unconfirmed = [HIBitcoinManager defaultManager].balanceUnconfirmed;
    uint64_t balance = [HIBitcoinManager defaultManager].balance;
    uint64_t fundsOnTheWay = balance_unconfirmed-balance;
    
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
        
        NSMutableParagraphStyle *paragraphStyle=[[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:NSRightTextAlignment];
        [paragraphStyle setMaximumLineHeight:10];
        [paragraphStyle setLineSpacing:1.0];
        
        NSFont *font2 = [NSFont boldSystemFontOfSize:9];
        NSDictionary *attrsDictionary2 = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:font2, [NSColor blackColor], paragraphStyle, nil]
                                                                     forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, NSParagraphStyleAttributeName, nil] ];
        NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",self.ticketValue, [[HIBitcoinManager defaultManager] formatNanobtc:balance]] attributes:attrsDictionary2];
        
        self.statusItem.attributedTitle = text;
    }
    else if(statusItemStyle == MWStatusItemStyleTicker)
    {
        self.statusItem.title = self.ticketValue;
        [self.secondRowItem setHidden:NO];
        
        // 2nd row is the wallet balance
        self.secondRowItem.title = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"secondLineBalanceLabel", @""), [[HIBitcoinManager defaultManager] formatNanobtc:balance]];
    }
    else
    {
        
        self.statusItem.title = [[HIBitcoinManager defaultManager] formatNanobtc:balance];
        
        // 2nd row is the ticker
        if(self.ticketValue.length > 0)
        {
            [self.secondRowItem setHidden:NO];
            
            NSString *optimizedString = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"secondLineTickerLabel", @""),self.ticketValue];
            
            NSString *tickerName = [[NSUserDefaults standardUserDefaults] objectForKey:kTICKER_NAME_KEY];
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
    
    [self rebuildTransactionsMenu];
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
        
        //TODO: restart app or bitcoin subsystem
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


#pragma mark - wallet/address stack

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
}

- (void)addWalletAddress:(id)sender
{
    [[HIBitcoinManager defaultManager] addKey];
    [self saveWallet];
    
    [self updateMyAddresses:[HIBitcoinManager defaultManager].allWalletAddresses];
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
    NSLog(@"%@", displayTransactions);
    
    // set font for transaction label
    NSFont *font = [NSFont systemFontOfSize:14];
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
    NSUInteger hiddenTransactions = MAX(totalTransactionCount - displayTransactions.count, 0);
    for(NSDictionary *transactionDict in displayTransactions)
    {
        
        long long amount = [[transactionDict objectForKey:@"amount"] longLongValue];
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
        
        MWTransactionMenuItem *menuItem = [[MWTransactionMenuItem alloc] initWithTitle:[NSString stringWithFormat:format, [[HIBitcoinManager defaultManager] formatNanobtc:amount], age ] action:@selector(transactionClicked:) keyEquivalent:@""];
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
    // keep window when user only moved the window to the backgroubd
    if(!self.sendCoinsWindowController)
    {
        self.sendCoinsWindowController = [[MWSendCoinsWindowController alloc] initWithWindowNibName:@"SendCoinsWindow"];
    }
    self.sendCoinsWindowController.delegate = self;
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.sendCoinsWindowController showWindow:nil];
    [self.sendCoinsWindowController.window orderFrontRegardless];
}

#pragma BASendCoinsWindowController Delegate
- (NSInteger)prepareSendCoinsFromWindowController:(MWSendCoinsWindowController *)windowController receiver:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis
{
    NSInteger fee = [[HIBitcoinManager defaultManager] prepareSendCoins:amountInSatoshis toReceipent:btcAddress comment:@""];
    
    return fee;
}
- (void)sendCoinsWindowControllerWillClose:(MWSendCoinsWindowController *)windowController
{
    // remove send coins window when user presses close button
    self.sendCoinsWindowController = nil;
}

#pragma mark - wallet stack

/*
 * saves the wallet to the osx keychain
 *
 */
- (void)saveWallet
{
    if(kSAVE_WALLET_TO_KEYCHAIN)
    {
        
        BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
        NSString *keychainServiceName = (testnet) ? kKEYCHAIN_SERVICE_NAME_TESTNET : kKEYCHAIN_SERVICE_NAME;
        
        NSString *base64str = [HIBitcoinManager defaultManager].walletFileBase64String;
        if(!base64str || base64str.length == 0)
        {
            return;
        }
        
        if(!RHKeychainDoesGenericEntryExist(NULL, keychainServiceName))
        {
            RHKeychainAddGenericEntry(NULL, keychainServiceName);
                RHKeychainSetGenericComment(NULL, keychainServiceName, @"bitcoinj wallet as base64 string");
        }
    
        RHKeychainSetGenericPassword(NULL, keychainServiceName, base64str);
    }
}

- (NSString *)loadWallet
{
    BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    NSString *keychainServiceName = (testnet) ? kKEYCHAIN_SERVICE_NAME_TESTNET : kKEYCHAIN_SERVICE_NAME;
    
    if(kSAVE_WALLET_TO_KEYCHAIN)
    {
        if(RHKeychainDoesGenericEntryExist(NULL, keychainServiceName))
        {
            return RHKeychainGetGenericPassword(NULL, keychainServiceName);
        }
        else
        {
            return nil;
        }
    }
}

#pragma mark - Preferences stack

- (IBAction)showPreferences:(id)sender {
    MWPreferenceGeneralViewController *generalPrefs = [[MWPreferenceGeneralViewController alloc] initWithNibName:@"MWPreferenceGeneralViewController" bundle:nil];
    MWPreferenceWalletViewController *walletPrefs = [[MWPreferenceWalletViewController alloc] initWithNibName:@"MWPreferenceWalletViewController" bundle:nil];
    
    NSArray *controllers = [NSArray arrayWithObjects:generalPrefs,walletPrefs,
                            nil];
    
    self.preferencesWindowController = [[RHPreferencesWindowController alloc] initWithViewControllers:controllers andTitle:NSLocalizedString(@"Preferences", @"Preferences Window Title")];
    [self.preferencesWindowController showWindow:self];
    [self.preferencesWindowController.window orderFrontRegardless];
}


#pragma mark - auto launch controlling stack

- (BOOL)launchAtStartup {
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL state = [launchController launchAtLogin];
    launchController = nil;
    return state;
}

- (void)setLaunchAtStartup:(BOOL)aState {
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
        [self updateStatusMenu];
        });
    }];
}


@end
