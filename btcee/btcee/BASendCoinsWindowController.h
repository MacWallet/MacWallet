//
//  BASendCoinsWindowController.h
//  btcee
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "BASendCoinsWindowControllerDelegate.h"

@class BAAppDelegate;

@interface BASendCoinsWindowController : NSWindowController
@property (strong) NSObject<BASendCoinsWindowControllerDelegate> *delegate;

- (void)txIsCommited:(NSString *)txHash;

@end
