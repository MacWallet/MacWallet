//
//  BAAppDelegate.h
//  MacWallet
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MWSendCoinsViewController.h"
#import "MWTransactionsWindowController.h"

@interface MWAppDelegate : NSObject <NSApplicationDelegate, MWSendCoinsWindowControllerDelegate, NSPopoverDelegate, NSMenuDelegate>

@property (assign) BOOL launchAtStartup;
@property (readonly) NSString* walletBasicEncryptionPassphrase;

@end