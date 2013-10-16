//
//  MWSendCoinsViewController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MWSendCoinsWindowControllerDelegate.h"

typedef enum MWSendCoinsWindowControllerState {
    MWSendCoinsWindowControllerBasic,
    MWSendCoinsWindowControllerWaitingCommit,
    MWSendCoinsWindowControllerShowTXID
} MWSendCoinsWindowControllerState;

@class MWAppDelegate;

@interface MWSendCoinsViewController : NSViewController
@property (strong) NSObject<MWSendCoinsWindowControllerDelegate> *delegate;
@property (strong) NSPopover *popover;
@end
