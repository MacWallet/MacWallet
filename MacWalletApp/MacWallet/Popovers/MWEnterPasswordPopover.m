//
//  MWEnterPasswordPopover.m
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWEnterPasswordPopover.h"

@interface MWEnterPasswordPopover ()
@property (strong) IBOutlet NSScrollView  *scrollView;
@property (strong) IBOutlet NSView  *containerView;
@property (strong) IBOutlet NSSecureTextField *passwordTextField;
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSButton *backButton;
@property (strong) IBOutlet NSTextField *responseTextField;

@property (assign) BOOL processFinished;
@end

@implementation MWEnterPasswordPopover

- (IBAction)backButtonPresses:(id)sender
{
    self.passwordTextField.stringValue = @"";
    [self showPageWithNumber:0];
}
- (IBAction)okPressed:(id)sender
{
    if(self.processFinished) {
        return;
    }
 
    if(self.okaySelector && self.okayTarget)
    {
//according to: http://stackoverflow.com/questions/9020438/how-to-declare-selector-as-a-property-ios-and-how-to-use-my-property-next
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.okayTarget performSelector:self.okaySelector withObject:self.passwordTextField.stringValue];
#pragma clang diagnostic pop

        return;
    }
    
    if(self.passwordTextField.stringValue)
    {
        // okay, set encryption
        [self showPageWithNumber:1];
        
        BOOL success = (BOOL)[self.delegate performSelector:@selector(shouldPerformRemoveEncryption:) withObject:self.passwordTextField.stringValue];
        if(!success)
        {
            [self.backButton setHidden:NO];
            [self.imageView setHidden:NO];
            
            self.responseTextField.stringValue = NSLocalizedString(@"errorDecryptingWallet", @"Error message in popup when trying to decyrpt wallet");
        }
        else
        {
            [self.backButton setHidden:YES];
            [self.imageView setHidden:YES];
            
            self.responseTextField.stringValue = NSLocalizedString(@"successDecryptingWallet", @"Success message in popup when trying to decyrpt wallet");
            self.processFinished = YES;
        }
    }
}

- (void)popoverWillShow:(NSNotification *)notification
{
    self.passwordTextField.stringValue = @"";
    self.processFinished = NO;

    // make password become active
    [self.passwordTextField becomeFirstResponder];
    
    [self.backButton setHidden:YES];
    [self.imageView setHidden:YES];
    [self.scrollView setDocumentView:self.containerView];
    
    [self showPageWithNumber:0];
}

@end
