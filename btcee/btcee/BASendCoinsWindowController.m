//
//  BASendCoinsWindowController.m
//  btcee
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BASendCoinsWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>

#define kBA_COINS_WINDOW_HEIGHT_NORMAL 128.0
#define kBA_COINS_WINDOW_HEIGHT_SEND 220.0
#define kBA_COINS_WINDOW_HEIGHT_COMMITTED 310.0
@interface BASendCoinsWindowController ()
@property (assign) IBOutlet NSTextField *btcAddressTextField;
@property (assign) IBOutlet NSTextField *amountTextField;
@property (assign) IBOutlet NSTextField *txFeeTextField;
@property (assign) IBOutlet NSTextField *txTotalAmountTextField;
@property (assign) IBOutlet NSTextField *commitedTxHash;

@property (assign) IBOutlet NSButton *prepareButton;
@property (assign) IBOutlet NSButton *commitButton;
@property (assign) IBOutlet NSButton *closeButton;

@property (assign) IBOutlet NSTextField *invalidTransactionTextField;
@property (assign) IBOutlet NSTextField *successAfterCommitTextField;

@end

@implementation BASendCoinsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    NSRect frame = self.window.frame;
    
    frame.size.height = kBA_COINS_WINDOW_HEIGHT_NORMAL;
    
    [self.window setFrame:frame display:YES animate:NO];
}

- (void)windowWillLoad
{
    [super windowWillLoad];

}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)prepareClicked:(id)sender
{
    
    NSInteger fee = [self.delegate prepareSendCoinsFromWindowController:self receiver:[self.btcAddressTextField stringValue] amount:[self.amountTextField doubleValue]*100000000 txfee:[self.txFeeTextField doubleValue]*100000000];
    
    if(fee != kHI_PREPARE_SEND_COINS_DID_FAIL)
    {
        NSRect frame = self.window.frame;
        
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_SEND - frame.size.height;
        
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_SEND;
        
        [self.window setFrame:frame display:YES animate:YES];
    
        
        self.txFeeTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:fee];
        self.txTotalAmountTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:[self.amountTextField doubleValue]*100000000+fee];
        
        [self.invalidTransactionTextField setHidden:YES];
        
        [self.prepareButton setEnabled:NO];
    }
    else
    {
        [self.invalidTransactionTextField setHidden:NO];
    }
}

- (IBAction)commitClicked:(id)sender
{
    NSString *txHash = [[HIBitcoinManager defaultManager] commitPreparedTransaction];
    
    if(txHash)
    {
        NSRect frame = self.window.frame;
        
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_COMMITTED - frame.size.height;
        
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_COMMITTED;
        
        [self.window setFrame:frame display:YES animate:YES];
        
        self.commitedTxHash.stringValue = txHash;
        
        [self.commitButton setEnabled:NO];
    }
}

- (IBAction)closeClicked:(id)sender
{
    [self close];
}

#pragma mark - prepare/send call ins
- (void)txIsCommited:(NSString *)txHash
{
    if(!txHash)
    {
        
    }
}

- (void)txCommitFailed:(NSString *)txHash
{
    if(!txHash)
    {
        
    }
}

- (void)windowWillClose:(id)sender
{
    [self.delegate sendCoinsWindowControllerWillClose:self];
}

#pragma mark - helper

- (NSString *)formatBTC:(NSString *)string
{
    NSNumberFormatter *formater;
}

@end
