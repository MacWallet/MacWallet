//
//  BASendCoinsWindowController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "MWSendCoinsWindowControllerDelegate.h"

typedef enum MWSendCoinsWindowControllerState {
    MWSendCoinsWindowControllerBasic,
    MWSendCoinsWindowControllerWaitingCommit,
    MWSendCoinsWindowControllerShowTXID
    } MWSendCoinsWindowControllerState;

@class MWAppDelegate;

@interface MWSendCoinsWindowController : NSWindowController <NSTextFieldDelegate>
@property (strong) NSObject<MWSendCoinsWindowControllerDelegate> *delegate;

@end
