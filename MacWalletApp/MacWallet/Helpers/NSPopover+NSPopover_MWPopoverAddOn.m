//
//  NSPopover+NSPopover_MWPopoverAddOn.m
//  MacWallet
//
//  Created by Jonas Schnelli on 11.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import "NSPopover+NSPopover_MWPopoverAddOn.h"

@implementation NSPopover (NSPopover_MWPopoverAddOn)


- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption cancelButton:(NSString *)cancelButton
{
    return [self showError:errorText continueOption:continueOption okayButton:NSLocalizedString(@"Continue", @"Continue Button") cancelButton:cancelButton];
}

- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption okayButton:(NSString *)okButton
{
    return [self showError:errorText continueOption:continueOption okayButton:okButton cancelButton:NSLocalizedString(@"No", @"No Button")];
}

- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption
{
    return [self showError:errorText continueOption:continueOption okayButton:NSLocalizedString(@"Continue", @"Continue Button") cancelButton:NSLocalizedString(@"No", @"No Button")];
}


- (NSInteger)showError:(NSString *)errorText continueOption:(BOOL)continueOption okayButton:(NSString *)okButton cancelButton:(NSString *)cancelButton
{
    NSAlert *alert = [[NSAlert alloc] init];
    if(continueOption)
    {
        [alert addButtonWithTitle:okButton];
    }
    [alert addButtonWithTitle:cancelButton];
    [alert setMessageText:errorText];
    [alert setInformativeText:@""];
    [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateIgnoringOtherApps];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    NSWindow* popoverWindow = self.contentViewController.view.window;
    NSInteger currentLevel = popoverWindow.level;
    [popoverWindow setLevel:NSNormalWindowLevel];
    
    NSInteger retVal = [alert runModal];
    
    [popoverWindow setLevel:currentLevel];
    
    return retVal;
}

@end
