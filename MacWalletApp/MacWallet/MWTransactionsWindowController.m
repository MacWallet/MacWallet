//
//  BATransactionsWindowController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 30.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import "MWTransactionsWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>

@interface MWTransactionsWindowController ()
@property (strong) NSArray *cachedTransactions;
@property (assign) IBOutlet NSTableView *tableView;
@property (assign) IBOutlet NSTableColumn *statusColumn;
@property (assign) IBOutlet NSTableColumn *amountColumn;
@property (assign) IBOutlet NSTableColumn *dateColumn;
@property (assign) IBOutlet NSTableColumn *addressColumn;
@property (assign) IBOutlet NSToolbarItem *getInfoToolbar;
@property (strong) NSDateFormatter *dateFormatter;
@end

@implementation MWTransactionsWindowController

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
  // do some localization stuff
    
    NSCell *cell = self.statusColumn.headerCell;
    cell.stringValue = NSLocalizedString(@"status", @"status column title");
    
    cell = self.amountColumn.headerCell;
    cell.stringValue = NSLocalizedString(@"amount", @"amount column title");
    
    cell = self.dateColumn.headerCell;
    cell.stringValue = NSLocalizedString(@"date", @"date column title");
    
    cell = self.addressColumn.headerCell;
    cell.stringValue = NSLocalizedString(@"receiverAddressLabel", @"receiverAddressLabel");
    
    self.getInfoToolbar.label = NSLocalizedString(@"getTxInfo", @"get transaction info label");
    self.window.title = NSLocalizedString(@"transactionsWindowTitle", @"transactionsWindowTitle");
    
    
    // set the double click action
    [self.tableView setDoubleAction:@selector(doubleClick:)];
}

- (void)showInfoForTxId:(NSString *)txHash
{
    NSDictionary *dict = [[HIBitcoinManager defaultManager] transactionForHash:txHash];
}

- (IBAction)showInfo:(id)sender
{
    NSDictionary *txDist = [self.cachedTransactions objectAtIndex:[self.tableView.selectedRowIndexes firstIndex]];
    NSString *txHash = [txDist objectForKey:@"txid"];

    [self showInfoForTxId:txHash];
}

- (void)doubleClick:(id)object {
    NSInteger rowNumber = [self.tableView clickedRow];
    NSDictionary *txDist = [self.cachedTransactions objectAtIndex:rowNumber];
    NSString *txHash = [txDist objectForKey:@"txid"];
    [self showInfoForTxId:txHash];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if(!self.dateFormatter)
    {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    if(!self.cachedTransactions)
    {
        self.cachedTransactions = [[HIBitcoinManager defaultManager] allTransactions:0];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.cachedTransactions.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSDictionary *txDist = [self.cachedTransactions objectAtIndex:rowIndex];
    if([aTableColumn.identifier isEqualToString:@"amount"]) {
        return [[HIBitcoinManager defaultManager] formatNanobtc:[[txDist objectForKey:@"amount"] longValue]];
    }
    else if([aTableColumn.identifier isEqualToString:@"date"]) {
        NSDate *date = [txDist objectForKey:@"time"];
        return [self.dateFormatter stringFromDate:date];
    }
    else if([aTableColumn.identifier isEqualToString:@"status"]) {
        if([[txDist objectForKey:@"confidence"] isEqualToString:@"building"])
        {
            return [NSImage imageNamed:@"TrustedCheckmark"];
        }
        return [NSImage imageNamed:@"Questionmark"];
    }
    else if([aTableColumn.identifier isEqualToString:@"recaddr"]) {
        NSDictionary *details = [[txDist objectForKey:@"details"] objectAtIndex:0];
        if(details)
        {
            return [details objectForKey:@"address"];
        }
        return @"";
    }
    return @"";
}


@end
