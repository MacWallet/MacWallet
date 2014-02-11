//
//  MWTransactionDetailsWindowController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 07.10.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import "MWTransactionDetailsWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>

@interface MWTransactionDetailsWindowController ()
@property (assign) IBOutlet NSTextField *transactionIdTextField;
@property (assign) IBOutlet NSTextField *amountTextField;
@property (assign) IBOutlet NSTextField *receiverAddressTextField;
@end

@implementation MWTransactionDetailsWindowController

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
    self.transactionIdTextField.stringValue = [self.txDict objectForKey:@"txid"];
    nanobtc_t amount = [[self.txDict objectForKey:@"amount"] longLongValue];
    self.amountTextField.stringValue = [[HIBitcoinManager defaultManager] formatNanobtc:amount withDesignator:YES];
    self.receiverAddressTextField.stringValue = [[[self.txDict objectForKey:@"details"] objectAtIndex:0] objectForKey:@"address"];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

@end
