//
//  NSStatusItem+NSStatusItem_i7MultipleMenuBarSupport.h
//  MacWallet
//
//  Created by Jonas Schnelli on 10.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSStatusItem (NSStatusItem_i7MultipleMenuBarSupport)

// gives back the NSWindow of the NSStatusItem on main screen (10.9+ multiple menu bars compatible)
- (NSWindow *)statusMenuItemWindowOnMainScreen;

@end
