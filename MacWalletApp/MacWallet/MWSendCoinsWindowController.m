//
//  BASendCoinsWindowController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import "MWSendCoinsWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>

#define kBA_COINS_WINDOW_HEIGHT_NORMAL 128.0
#define kBA_COINS_WINDOW_HEIGHT_SEND 220.0
#define kBA_COINS_WINDOW_HEIGHT_COMMITTED 310.0
@interface MWSendCoinsWindowController ()
@property (assign) IBOutlet NSTextField *btcAddressTextField;
@property (assign) IBOutlet NSTextField *amountTextField;
@property (assign) IBOutlet NSTextField *txFeeTextField;
@property (assign) IBOutlet NSTextField *txTotalAmountTextField;
@property (assign) IBOutlet NSTextField *commitedTxHash;

@property (assign) IBOutlet NSTextField *receiverAddressLabel;
@property (assign) IBOutlet NSTextField *amoutLabel;
@property (assign) IBOutlet NSTextField *feeLabel;
@property (assign) IBOutlet NSTextField *totalAmountLabel;
@property (assign) IBOutlet NSTextField *transactionIdLabel;

@property (assign) IBOutlet NSButton *prepareButton;
@property (assign) IBOutlet NSButton *commitButton;
@property (assign) IBOutlet NSButton *closeButton;

@property (assign) IBOutlet NSTextField *invalidTransactionTextField;
@property (assign) IBOutlet NSTextField *successAfterCommitTextField;

@property (assign) MWSendCoinsWindowControllerState currentState;

@end

@implementation MWSendCoinsWindowController

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
    // keep track of the state
    self.currentState = MWSendCoinsWindowControllerBasic;
    
    // set to normal height
    NSRect frame = self.window.frame;
    frame.size.height = kBA_COINS_WINDOW_HEIGHT_NORMAL;
    [self.window setFrame:frame display:YES animate:NO];
    
    // do some localization stuff
    self.receiverAddressLabel.stringValue   = NSLocalizedString(@"receiverAddressLabel", @"receiverAddressLabel");
    self.amoutLabel.stringValue             = NSLocalizedString(@"amoutLabel", @"amoutLabel");
    self.feeLabel.stringValue               = NSLocalizedString(@"feeLabel", @"feeLabel");
    self.totalAmountLabel.stringValue       = NSLocalizedString(@"totalAmountLabel", @"totalAmountLabel");
    self.transactionIdLabel.stringValue     = NSLocalizedString(@"transactionIdLabel", @"transactionIdLabel");
    
    self.prepareButton.title                = NSLocalizedString(@"prepareTx", @"prepareTx");
    self.commitButton.title                 = NSLocalizedString(@"commitTx", @"prepareTx");
    self.closeButton.title                  = NSLocalizedString(@"closeButton", @"prepareTx");
    
    self.window.title = NSLocalizedString(@"sendCoinsWindowTitle", @"sendCoinsWindowTitle");
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
        self.currentState = MWSendCoinsWindowControllerWaitingCommit;
        
        NSRect frame = self.window.frame;
        
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_SEND - frame.size.height;
        
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_SEND;
        
        [self.window setFrame:frame display:YES animate:YES];
    
        
        self.txFeeTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:fee];
        self.txTotalAmountTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:[self.amountTextField doubleValue]*100000000+fee];
        
        [self.invalidTransactionTextField setHidden:YES];
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
        self.currentState = MWSendCoinsWindowControllerShowTXID;
        
        NSRect frame = self.window.frame;
        
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_COMMITTED - frame.size.height;
        
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_COMMITTED;
        
        [self.window setFrame:frame display:YES animate:YES];
        
        self.commitedTxHash.stringValue = txHash;
        
        [self.btcAddressTextField setEditable:NO];
        [self.amountTextField setEditable:NO];
        
        [self.prepareButton setEnabled:NO];
        [self.commitButton setEnabled:NO];
    }
}

- (IBAction)closeClicked:(id)sender
{
    [self close];
}

- (void)windowWillClose:(id)sender
{
    [self.delegate sendCoinsWindowControllerWillClose:self];
}

#pragma mark - NSTextField delegate stack

- (void)controlTextDidChange:(NSNotification *)notification
{
    if(self.currentState == MWSendCoinsWindowControllerWaitingCommit)
    {
        NSRect frame = self.window.frame;
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_NORMAL - frame.size.height;
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_NORMAL;
        [self.window setFrame:frame display:YES animate:YES];
        
        self.txFeeTextField.stringValue             = @"";
        self.txTotalAmountTextField.stringValue     = @"";
    }
}

@end
