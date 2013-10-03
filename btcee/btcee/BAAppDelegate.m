//
//  BAAppDelegate.m
//  btcee
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BAAppDelegate.h"
#import <BitcoinJKit/BitcoinJKit.h>
#import "RHKeychain.h"
#import "LaunchAtLoginController.h"
#import "RHPreferencesWindowController.h"
#import "I7SPreferenceGeneralViewController.h"
#import "BAPreferenceWalletViewController.h"

@interface BAAppDelegate ()

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

@property (assign) BOOL useKeychain;

@property (strong) BASendCoinsWindowController *sendCoinsWindowController;
@property (strong) BATransactionsWindowController *txWindowController;

@property (strong) RHPreferencesWindowController * preferencesWindowController;

@end

@implementation BAAppDelegate


// main entry point
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
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
    [self.statusItem setTitle:@"BTCEE"];
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
        [HIBitcoinManager defaultManager].appName = @"btcee_testnet";
    }
    else
    {
        [HIBitcoinManager defaultManager].appName = @"btcee";
    }
    
    [HIBitcoinManager defaultManager].appSupportDirectoryIdentifier = @"Btcee";
    
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
    
    self.balanceUnconfirmedMenuItem.attributedTitle = string;
    self.statusItem.title = [[HIBitcoinManager defaultManager] formatNanobtc:balance];
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
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%@ ago)", [[HIBitcoinManager defaultManager] formatNanobtc:amount], age ] action:@selector(transactionClicked:) keyEquivalent:@""];
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
    [self updateStatusMenu];
}

- (IBAction)showTransactionWindow:(id)sender
{
    self.txWindowController = [[BATransactionsWindowController alloc] initWithWindowNibName:@"BATransactionsWindowController"];
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.txWindowController showWindow:nil];
    [self.txWindowController.window orderFrontRegardless];
}

#pragma mark - send coins stack
- (IBAction)openSendCoins:(id)sender
{
    // keep window when user only moved the window to the backgroubd
    if(!self.sendCoinsWindowController)
    {
        self.sendCoinsWindowController = [[BASendCoinsWindowController alloc] initWithWindowNibName:@"SendCoinsWindow"];
    }
    self.sendCoinsWindowController.delegate = self;
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.sendCoinsWindowController showWindow:nil];
    [self.sendCoinsWindowController.window orderFrontRegardless];
}

#pragma BASendCoinsWindowController Delegate
- (NSInteger)prepareSendCoinsFromWindowController:(BASendCoinsWindowController *)windowController receiver:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis
{
    NSInteger fee = [[HIBitcoinManager defaultManager] prepareSendCoins:amountInSatoshis toReceipent:btcAddress comment:@""];
    
    return fee;
}
- (void)sendCoinsWindowControllerWillClose:(BASendCoinsWindowController *)windowController
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
    I7SPreferenceGeneralViewController *generalPrefs = [[I7SPreferenceGeneralViewController alloc] initWithNibName:@"I7SPreferenceGeneralViewController" bundle:nil];
    BAPreferenceWalletViewController *walletPrefs = [[BAPreferenceWalletViewController alloc] initWithNibName:@"BAPreferenceWalletViewController" bundle:nil];
    
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

#pragma mark - helpers


@end
