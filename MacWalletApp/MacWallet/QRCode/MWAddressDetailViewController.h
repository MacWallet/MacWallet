//
//  MWQRCodeViewController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 21.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MWAddressDetailViewController : NSViewController
@property (strong) NSPopover *popover;
@property (strong) NSImage *qrCodeImageToShow;
@property (strong) NSString *addressToShow;
@end
