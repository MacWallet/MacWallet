//
//  BATransactionsWindowController.m
//  btcee
//
//  Created by Jonas Schnelli on 30.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BATransactionsWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>

@interface BATransactionsWindowController ()
@property (strong) NSArray *cachedTransactions;
@property (assign) IBOutlet NSTableView *tableView;
@property (strong) NSDateFormatter *dateFormatter;
@end

@implementation BATransactionsWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)showInfo:(id)sender
{
    
    NSDictionary *txDist = [self.cachedTransactions objectAtIndex:[self.tableView.selectedRowIndexes firstIndex]];
    NSString *txHash = [txDist objectForKey:@"txid"];
    NSDictionary *dict = [[HIBitcoinManager defaultManager] transactionForHash:txHash];
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
