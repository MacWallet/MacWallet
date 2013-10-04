//
//  BASendCoinsWindowController.h
//  btcee
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "BASendCoinsWindowControllerDelegate.h"

typedef enum BASendCoinsWindowControllerState {
    BASendCoinsWindowControllerBasic,
    BASendCoinsWindowControllerWaitingCommit,
    BASendCoinsWindowControllerShowTXID
    } BASendCoinsWindowControllerState;

@class BAAppDelegate;

@interface BASendCoinsWindowController : NSWindowController <NSTextFieldDelegate>
@property (strong) NSObject<BASendCoinsWindowControllerDelegate> *delegate;

@end
