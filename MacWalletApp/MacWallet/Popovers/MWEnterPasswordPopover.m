//
//  MWEnterPasswordPopover.m
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWEnterPasswordPopover.h"
#import "HIPasswordHolder.h"
#import "NSPopover+NSPopover_MWPopoverAddOn.h"

@interface MWEnterPasswordPopover ()
@property (strong) IBOutlet NSScrollView  *scrollView;
@property (strong) IBOutlet NSView  *containerView;
@property (strong) IBOutlet NSSecureTextField *passwordTextField;
@property (strong) IBOutlet NSImageView *imageView;
@property (strong) IBOutlet NSButton *backButton0;
@property (strong) IBOutlet NSButton *backButton1;
@property (strong) IBOutlet NSTextField *responseTextField;

@property (strong) IBOutlet NSTextField *enterPasswordLabel;
@property (strong) IBOutlet NSTextField *lastMassageLabel;

@property (strong) IBOutlet NSButton *okButton0;
@property (strong) IBOutlet NSButton *okButton1;

@property (assign) BOOL processFinished;
@end

@implementation MWEnterPasswordPopover

-(void)awakeFromNib
{
    // do some i18n
    
    
    self.backButton0.title                  = NSLocalizedString(@"enterPasswordBackButton0Text", @"");
    self.backButton1.title                  = NSLocalizedString(@"enterPasswordBackButton1Text", @"");
    self.okButton0.title                    = NSLocalizedString(@"enterPasswordOkButton0Text", @"");
    self.okButton1.title                    = NSLocalizedString(@"enterPasswordOkButton1Text", @"");
    self.lastMassageLabel.stringValue       = NSLocalizedString(@"enterPasswordLastMessage", @"");
    self.enterPasswordLabel.stringValue     = NSLocalizedString(@"enterPasswordPassword0PlaceholderText", @"");
    [(NSTextFieldCell *)self.passwordTextField.cell setPlaceholderString:NSLocalizedString(@"enterPasswordPassword0PlaceholderText", @"")];

}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)fieldEditor doCommandBySelector:(SEL)commandSelector
{
    BOOL retval = NO;
    if (commandSelector == @selector(insertNewline:))
    {
        retval = YES; // causes Apple to NOT fire the default enter action
        [self okPressed:self];
    }
    
    return retval;
}

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
        
        NSInteger retVal = [self showError:NSLocalizedString(@"confirmQuestionPermanentlyDecryptWallet", @"A confirm question when user likes to permanently decrypt his wallet") continueOption:YES];
        
        if(retVal != NSAlertFirstButtonReturn)
        {
            // cancel pressed
            return;
        }
        
        // okay, set encryption
        [self showPageWithNumber:1];
        
        HIPasswordHolder *passwordHolder = [[HIPasswordHolder alloc] initWithString:self.passwordTextField.stringValue];
        
        BOOL success = (BOOL)[self.delegate performSelector:@selector(shouldPerformRemoveEncryption:) withObject:passwordHolder];
        [passwordHolder clear];
        
        if(!success)
        {
            [self.backButton1 setHidden:NO];
            [self.imageView setHidden:NO];
            
            self.responseTextField.stringValue = NSLocalizedString(@"errorDecryptingWallet", @"Error message in popup when trying to decyrpt wallet");
        }
        else
        {
            [self.backButton1 setHidden:YES];
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
    
    [self.backButton1 setHidden:YES];
    [self.imageView setHidden:YES];
    [self.scrollView setDocumentView:self.containerView];
    
    [self showPageWithNumber:0];
    
    // reset the size, osx 10.7 issue
    self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y,230,109);
}


@end
