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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
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
        return [txDist objectForKey:@"time"];
    }
    return @"";
}


@end
