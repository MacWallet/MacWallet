//
//  NSPopover+NSPopover_MWPopoverAddOn.h
//  MacWallet
//
//  Created by Jonas Schnelli on 11.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPopover (NSPopover_MWPopoverAddOn)

- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption cancelButton:(NSString *)cancelButton;
- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption okayButton:(NSString *)okButton;
- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption;

- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption okayButton:(NSString *)okButton cancelButton:(NSString *)cancelButton;

@end
