//
//  BAAppDelegate.m
//  btcee
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BAAppDelegate.h"
#import <BitcoinJKit/BitcoinJKit.h>

@interface BAAppDelegate ()

@property (strong) NSStatusItem * statusItem;
@property (assign) IBOutlet NSMenu *statusMenu;
@property (assign) IBOutlet NSMenu *addressesMenu;
@property (assign) IBOutlet NSMenu *transactionsMenu;
@property (assign) IBOutlet NSMenuItem *networkStatusMenuItem;
@property (assign) IBOutlet NSMenuItem *networkStatusPeersMenuItem;
@property (assign) IBOutlet NSMenuItem *networkStatusBlockHeight;
@property (assign) IBOutlet NSMenuItem *networkStatusNetSwitch;

@property (assign) IBOutlet NSMenuItem *balanceUnconfirmedMenuItem;

@property (strong) IBOutlet BASendCoinsWindowController *sendCoinsWindowController;

@end

@implementation BAAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    CGFloat menuWidth = 90.0;
    
    // make a global menu (extra menu) item
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setMenu:self.statusMenu];
    [self.statusItem setTitle:@"BTCEE"];
    [self.statusItem setHighlightMode:YES];
    
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"connections" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"balance" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"syncProgress" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"isRunning" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    [[HIBitcoinManager defaultManager] addObserver:self forKeyPath:@"peerCount" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:NULL];
    
    BOOL testnet = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    
    [HIBitcoinManager defaultManager].testingNetwork = testnet;

    if(testnet)
    {
        [HIBitcoinManager defaultManager].appName = @"btcee_testnet";
    }
    else
    {
        [HIBitcoinManager defaultManager].appName = @"btcee";
    }
    
    [HIBitcoinManager defaultManager].appSupportDirectoryIdentifier = @"Btcee";

    
    [[HIBitcoinManager defaultManager] start];
    
    [self updateNetworkMenuItem];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [HIBitcoinManager defaultManager])
    {
        if ([keyPath compare:@"connections"] == NSOrderedSame)
        {
            NSLog(@"conn: %@", [NSString stringWithFormat:@"%lu", [HIBitcoinManager defaultManager].connections]);
        }
        else if ([keyPath compare:@"balance"] == NSOrderedSame)
        {
            
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
                NSLog(@"status: isrunning, syncing");
                NSLog(@"status: my address: %@", [HIBitcoinManager defaultManager].walletAddress);
                
                NSString *base64 = [HIBitcoinManager defaultManager].walletFileBase64String;
                [self updateMyAddresses:[HIBitcoinManager defaultManager].allWalletAddresses];
                
                [self updateStatusMenu];
            }
        }
        else if ([keyPath compare:@"syncProgress"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].syncProgress < 1.0)
            {
                self.networkStatusMenuItem.title =[NSString stringWithFormat:@"Syncing: %d%%",(int)round((double)[HIBitcoinManager defaultManager].syncProgress*100)];
            }
            else {
                // sync okay
                self.networkStatusMenuItem.title = NSLocalizedString(@"Network: synced", @"Network Menu Item Synced");
                
                [self updateStatusMenu];
            }
            
            NSLog(@"==========> total1: %ld", (long)[HIBitcoinManager defaultManager].totalBlocks);
            
            self.networkStatusBlockHeight.title = [NSString stringWithFormat:@"Blocks: %ld/%ld",[HIBitcoinManager defaultManager].currentBlockCount, [HIBitcoinManager defaultManager].totalBlocks];
            
        }
        else if ([keyPath compare:@"peerCount"] == NSOrderedSame)
        {
            self.networkStatusPeersMenuItem.title = [NSString stringWithFormat:@"Connected Peers: %lu", (unsigned long)[HIBitcoinManager defaultManager].peerCount];
        }
    }
}

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
    NSDictionary *attrsDictionary =
    [NSDictionary dictionaryWithObject:font
                                forKey:NSFontAttributeName];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:NSLocalizedString(@"Funds on the way:\n%@",@"Funds on the way menu item"), [self formatBTC:fundsOnTheWay]] attributes:attrsDictionary];
    
    
    self.balanceUnconfirmedMenuItem.attributedTitle = string;
    
    self.statusItem.title = [self formatBTC:balance];
    
    [self rebuildTransactionsMenu];
}

#pragma mark - menu actions

- (IBAction)testnetSwitchChecked:(NSMenuItem *)sender
{
    BOOL testnetOn = [[NSUserDefaults standardUserDefaults] boolForKey:kTESTNET_SWITCH_KEY];
    [[NSUserDefaults standardUserDefaults] setBool:!testnetOn forKey:kTESTNET_SWITCH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateNetworkMenuItem];
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
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", [self formatBTC:amount]] action:@selector(transactionClicked:) keyEquivalent:@""];
        if([[transactionDict objectForKey:@"confidence"] isEqualToString:@"building"])
        {
            [menuItem setImage:[NSImage imageNamed:@"TrustedCheckmark"]];
        }
        else
        {
            [menuItem setImage:nil];
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
        [self.transactionsMenu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"%d more...", @"more transaction menu item"), hiddenTransactions] action:nil keyEquivalent:@""];
    }
    // add a separator as well as a "show all transaction" menu item
    [self.transactionsMenu addItem:[NSMenuItem separatorItem]];
    
    [self.transactionsMenu addItemWithTitle:NSLocalizedString(@"showAllTransaction", @"Show All Transaction Menu Item") action:@selector(addWalletAddress:) keyEquivalent:@""];
}
    
- (void)transactionClicked:(id)sender
{
    [self updateStatusMenu];
}


#pragma mark - send coins stack
- (IBAction)openSendCoins:(id)sender
{
    // keep window when user only moved the window to the backgroubd
    if(!self.sendCoinsWindowController)
    {
        self.sendCoinsWindowController = [[BASendCoinsWindowController alloc] initWithWindowNibName:@"SendCoinsWindow"];
        self.sendCoinsWindowController.delegate = self;
    }
    
    // activate the app so that the window popps to front
    [NSApp activateIgnoringOtherApps:YES];
    
    [self.sendCoinsWindowController showWindow:nil];
    [self.sendCoinsWindowController.window orderFrontRegardless];
}

#pragma BASendCoinsWindowController Delegate
- (void)sendCoinsFromWindowController:(BASendCoinsWindowController *)windowController receiver:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis
{
    [[HIBitcoinManager defaultManager] sendCoins:amountInSatoshis toReceipent:btcAddress comment:@"" completion:nil];
}
- (void)sendCoinsWindowControllerWillClose:(BASendCoinsWindowController *)windowController
{
    // remove send coins window when user presses close button
    self.sendCoinsWindowController = nil;
}


#pragma mark - helpers

- (NSString *)formatBTC:(NSInteger)btc
{
    //TODO: nice and configurable
    return [NSString stringWithFormat:@"%.4f ฿", (double)btc/100000000];
}


@end
