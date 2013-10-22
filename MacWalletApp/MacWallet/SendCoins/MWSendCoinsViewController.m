//
//  MWSendCoinsViewController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWSendCoinsViewController.h"
#import <BitcoinJKit/BitcoinJKit.h>
#import "MWAppDelegate.h"
#import "DuxScrollViewAnimation.h"

#define kBA_COINS_WINDOW_HEIGHT_NORMAL 128.0
#define kBA_COINS_WINDOW_HEIGHT_SEND 215.0
#define kBA_COINS_WINDOW_HEIGHT_COMMITTED 330.0

@interface MWSendCoinsViewController ()
@property (assign) IBOutlet NSScrollView *scrollView;

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
@property (assign) IBOutlet NSButton *closeButton0;
@property (assign) IBOutlet NSButton *closeButton1;

@property (assign) IBOutlet NSTextField *invalidTransactionTextField;
@property (assign) IBOutlet NSTextField *successAfterCommitTextField;

@property (assign) MWSendCoinsWindowControllerState currentState;

@property (strong) IBOutlet NSPanel *passwordPromt;
@property (assign) IBOutlet NSTextField *passwordTextField;

@property (strong) IBOutlet NSView  *containerView;


@end

@implementation MWSendCoinsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)awakeFromNib
{
    [self.scrollView setDocumentView:self.containerView];
    [DuxScrollViewAnimation animatedScrollToPoint:NSMakePoint(0,300) inScrollView:self.scrollView];
    
    // keep track of the state
    self.currentState = MWSendCoinsWindowControllerBasic;
    
    // set to normal height
    NSRect frame = self.view.frame;
    frame.size.height = kBA_COINS_WINDOW_HEIGHT_NORMAL;
    
    // do some localization stuff
    self.receiverAddressLabel.stringValue   = NSLocalizedString(@"receiverAddressLabel", @"receiverAddressLabel");
    self.amoutLabel.stringValue             = NSLocalizedString(@"amoutLabel", @"amoutLabel");
    self.feeLabel.stringValue               = NSLocalizedString(@"feeLabel", @"feeLabel");
    self.totalAmountLabel.stringValue       = NSLocalizedString(@"totalAmountLabel", @"totalAmountLabel");
    self.transactionIdLabel.stringValue     = NSLocalizedString(@"transactionIdLabel", @"transactionIdLabel");
    
    self.prepareButton.title                = NSLocalizedString(@"prepareTx", @"prepareTx");
    self.commitButton.title                 = NSLocalizedString(@"commitTx", @"commitTx");
    self.closeButton0.title                 = NSLocalizedString(@"closeButton", @"close button text");
    self.closeButton1.title                 = NSLocalizedString(@"closeButton", @"close button text");

    self.successAfterCommitTextField.stringValue  = NSLocalizedString(@"transactionSuccessText", @"transactionSuccessText");
    
    [self.passwordPromt setReleasedWhenClosed:NO];
    
    [self.btcAddressTextField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.2];
}

- (IBAction)prepareClicked:(id)sender
{
    BOOL hasEncryptedWallet = [[HIBitcoinManager defaultManager] isWalletEncrypted];
    // check if wallet is encryped
    if(hasEncryptedWallet)
    {
        [self showPasswordPrompt:sender];
    }
    else
    {
        // continue without password
        [self prepareTransactionWithWalletPassword:nil];
    }
}

- (void)prepareTransactionWithWalletPassword:(NSString *)password
{
    NSInteger fee = [self.delegate prepareSendCoinsFromWindowController:self receiver:[self.btcAddressTextField stringValue] amount:[self.amountTextField doubleValue]*100000000 txfee:0 password:password];
    
    if(fee >= 0)
    {
        self.currentState = MWSendCoinsWindowControllerWaitingCommit;

        self.txFeeTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:fee];
        self.txTotalAmountTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:[self.amountTextField doubleValue]*100000000+fee];
        
        [self.invalidTransactionTextField setHidden:YES];
        
        [self.popover setContentSize:NSMakeSize(self.view.frame.size.width, kBA_COINS_WINDOW_HEIGHT_SEND)];
        
    }
    else
    {
        if(fee == -1)
        {
            // encryption problem
            self.invalidTransactionTextField.stringValue = NSLocalizedString(@"passwordWrong", @"send coins wrong password text");
        }
        else if(fee == -2)
        {
            // not enought money problem
            self.invalidTransactionTextField.stringValue = NSLocalizedString(@"insufficientFunds", @"send coins insufficient funds text");
        }
        else
        {
            // hack for detecting insufficient funds while bitcoinj don't report this at the moment
            
            double calcFee = 0.0001;
            double balance = [HIBitcoinManager defaultManager].balance;
            double txVal =([self.amountTextField doubleValue] + calcFee);
            if(txVal > balance/100000000)
            {
                // not enought money problem
                self.invalidTransactionTextField.stringValue = NSLocalizedString(@"insufficientFunds", @"send coins insufficient funds text");
            }
            else
            {
                // not enought money problem
                self.invalidTransactionTextField.stringValue = NSLocalizedString(@"unknownSendCoinsError", @"send coins unknown error text");
            }
        }
        [self.invalidTransactionTextField setHidden:NO];
    }
}

- (IBAction)commitClicked:(id)sender
{
    NSString *txHash = [[HIBitcoinManager defaultManager] commitPreparedTransaction];
    
    if(txHash)
    {
        self.currentState = MWSendCoinsWindowControllerShowTXID;
        
        [self.popover setContentSize:NSMakeSize(self.view.frame.size.width, kBA_COINS_WINDOW_HEIGHT_COMMITTED)];
        
        self.commitedTxHash.stringValue = txHash;
        
        [self.btcAddressTextField setEditable:NO];
        [self.amountTextField setEditable:NO];
        
        [self.prepareButton setEnabled:NO];
        [self.commitButton setEnabled:NO];
    }
}

- (IBAction)closeClicked:(id)sender
{
    [self.popover performClose:self];
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
        NSRect frame = self.view.frame;
        CGFloat heightShift = kBA_COINS_WINDOW_HEIGHT_NORMAL - frame.size.height;
        frame.origin.y -= heightShift;
        frame.size.height = kBA_COINS_WINDOW_HEIGHT_NORMAL;

        self.txFeeTextField.stringValue             = @"";
        self.txTotalAmountTextField.stringValue     = @"";
    }
}

-(IBAction)showPasswordPrompt:(id)sender
{
    [[NSApplication sharedApplication] beginSheet:self.passwordPromt
                                   modalForWindow:self.view.window
                                    modalDelegate:self
                                   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
                                      contextInfo:nil];
    
}

- (IBAction)closePasswordPrompt:(id)sender
{
    NSButton *clickedButton = (NSButton *)sender;
    
    [NSApp endSheet:self.passwordPromt returnCode:NSOKButton];
    [self.passwordPromt orderOut:sender];
    
    if(clickedButton.tag == 1 || clickedButton.tag == 2)
    {
        [self prepareTransactionWithWalletPassword:self.passwordTextField.stringValue];
        self.passwordTextField.stringValue = @"";
    }
}

@end
