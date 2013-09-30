//
//  BAAppDelegate.h
//  btcee
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BASendCoinsWindowController.h"
#import "BATransactionsWindowController.h"

@interface BAAppDelegate : NSObject <NSApplicationDelegate, BASendCoinsWindowControllerDelegate>

@property (assign) IBOutlet NSWindow *window;

- (void)sendCoins:(NSString *)btcAddress amount:(NSInteger)satoshis txfee:(NSInteger)satoshis;

@end
