//
//  BASendCoinsWindowController.m
//  btcee
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BASendCoinsWindowController.h"

@interface BASendCoinsWindowController ()
@property (assign) IBOutlet NSTextField *btcAddressTextField;
@property (assign) IBOutlet NSTextField *amountTextField;
@property (assign) IBOutlet NSTextField *txFeeTextField;
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

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:nil];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)sendClicked:(id)sender
{
    [self.delegate sendCoinsFromWindowController:self receiver:[self.btcAddressTextField stringValue] amount:[self.amountTextField doubleValue]*100000000 txfee:[self.txFeeTextField doubleValue]*100000000];
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
