//
//  MWCreateWalletController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 05.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MWCreateWalletControllerDelegate.h"
@interface MWCreateWalletController : NSViewController
@property (strong) NSPopover *popover;
@property (strong) NSObject <MWCreateWalletControllerDelegate> *delegate;
@end
