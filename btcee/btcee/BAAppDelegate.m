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

- (void)updateMyAddresses:(NSArray *)addresses
{
    NSLog(@"%@", addresses);
    [self.addressesMenu removeAllItems];
    
    for(NSString *address in addresses)
    {
        [self.addressesMenu addItemWithTitle:address action:@selector(addressClicked:) keyEquivalent:@""];
    }
    
    // add seperator and a "add address" menu item
    [self.addressesMenu addItem:[NSMenuItem separatorItem]];
    [self.addressesMenu addItemWithTitle:NSLocalizedString(@"addAddress", @"Add Address Menu Item") action:@selector(addWalletAddress:) keyEquivalent:@""];
}
    
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
            }
        }
        else if ([keyPath compare:@"syncProgress"] == NSOrderedSame)
        {
            if ([HIBitcoinManager defaultManager].syncProgress < 1.0)
            {
                self.networkStatusMenuItem.title =[NSString stringWithFormat:@"Syncing: %d%%",(int)round((double)[HIBitcoinManager defaultManager].syncProgress*100)];
                
                self.networkStatusBlockHeight.title = [NSString stringWithFormat:@"Blocks: %d/%d",[HIBitcoinManager defaultManager].currentBlockCount, [HIBitcoinManager defaultManager].totalBlocks];
            }
            else {
                // sync okay
                self.networkStatusMenuItem.title = NSLocalizedString(@"Network: synced", @"Network Menu Item Synced");
                
                
                NSLog(@"bal: %@",  [NSString stringWithFormat:@"%.4f ฿", (CGFloat)[HIBitcoinManager defaultManager].balance / 100000000.0]);
                
                
                
                self.statusItem.title = [NSString stringWithFormat:@"%.4f ฿", (CGFloat)[HIBitcoinManager defaultManager].balance / 100000000.0];
            }
        }
        else if ([keyPath compare:@"peerCount"] == NSOrderedSame)
        {
            self.networkStatusPeersMenuItem.title = [NSString stringWithFormat:@"Connected Peers: %lu", (unsigned long)[HIBitcoinManager defaultManager].peerCount];
        }
    }
}
    
- (void)rebuildTransactionsMenu
{
    // remove all menu items and recreate the transaction menu
    [self.transactionsMenu removeAllItems];
    NSArray *transactions =  [[HIBitcoinManager defaultManager] allTransactions];
    NSLog(@"%@", transactions);
    for(NSDictionary *transactionDict in transactions)
    {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@", [self formatBTC:[[transactionDict objectForKey:@"amount"] longLongValue]]] action:@selector(transactionClicked:) keyEquivalent:@""];
        if([[transactionDict objectForKey:@"confidence"] isEqualToString:@"building"])
        {
            [menuItem setImage:[NSImage imageNamed:@"TrustedCheckmark"]];
        }
        else
        {
            [menuItem setImage:nil];
        }
        
        [self.transactionsMenu addItem:menuItem];
    }
    if(transactions.count == 0)
    {
        [self.transactionsMenu addItemWithTitle:NSLocalizedString(@"noTransactionsFound", @"No Transactions Found Menu Item") action:nil keyEquivalent:@""];
    }
    
    // add a separator as well as a "show all transaction" menu item
    [self.transactionsMenu addItem:[NSMenuItem separatorItem]];
    [self.transactionsMenu addItemWithTitle:NSLocalizedString(@"showAllTransaction", @"Show All Transaction Menu Item") action:@selector(addWalletAddress:) keyEquivalent:@""];
}
    
- (void)transactionClicked:(id)sender
{
    
}

- (void)updateStatusMenu
{
    self.statusItem.title = [self formatBTC:[HIBitcoinManager defaultManager].balance / 100000000.0];
}
    
- (NSString *)formatBTC:(NSInteger)btc
{
    //TODO: nice and configurable
    return [NSString stringWithFormat:@"%.4f ฿", (double)btc/100000000];
}

- (void)sendCoins:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis
{
    
}

- (IBAction)openSendCoins:(id)sender
{
    // keep window when user only moved the window to the backgroubd
    if(!self.sendCoinsWindowController)
    {
        self.sendCoinsWindowController = [[BASendCoinsWindowController alloc] initWithWindowNibName:@"SendCoinsWindow"];
        self.sendCoinsWindowController.delegate = self;
    }
    NSLog(@"%@", self.sendCoinsWindowController.window);
    
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
@end
