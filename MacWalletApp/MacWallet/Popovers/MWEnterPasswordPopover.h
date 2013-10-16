//
//  MWEnterPasswordPopover.h
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MWBasePopover.h"

@interface MWEnterPasswordPopover : MWBasePopover
@property (assign) SEL okaySelector;
@property (assign) NSObject *okayTarget;
@end
