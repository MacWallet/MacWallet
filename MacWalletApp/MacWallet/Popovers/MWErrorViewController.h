//
//  MWErrorViewController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 03.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MWErrorViewController : NSViewController
@property (strong) NSString *textToShow;
@property (strong) NSString *detailedText;
@property (strong) NSPopover *popover;
@end
