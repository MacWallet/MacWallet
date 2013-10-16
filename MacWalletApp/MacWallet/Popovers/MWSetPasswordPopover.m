//
//  MWSetPasswordPopover.m
//  MacWallet
//
//  Created by Jonas Schnelli on 11.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWSetPasswordPopover.h"
#import "DuxScrollViewAnimation.h"
#import "passwordChecker.h"

@interface MWSetPasswordPopover ()
@property (strong) IBOutlet NSView  *containerView;
@property (strong) IBOutlet NSScrollView  *scrollView;

@property (strong) IBOutlet NSTextField *password0;
@property (strong) IBOutlet NSTextField *password1;

@property (strong) IBOutlet NSButton *okButton0;
@property (strong) IBOutlet NSButton *okButton1;

@property (strong) IBOutlet NSButton *abortButton0;
@property (strong) IBOutlet NSButton *abortButton1;

@property (strong) IBOutlet NSImageView *imageView0;
@property (strong) IBOutlet NSTextField *pwStrength;
@property (strong) IBOutlet NSLevelIndicator *pwStrengthLevel;

@property (strong) IBOutlet NSImageView *noMatchImageView;
@property (assign) BOOL processFinished;

@end

@implementation MWSetPasswordPopover

-(void)controlTextDidChange:(NSNotification *)notification {
    
    if(notification.object == self.password1)
    {
        if([self.password0.stringValue isEqualToString:self.password1.stringValue])
        {
            self.noMatchImageView.image = [NSImage imageNamed:@"ok_small"];
            [self.noMatchImageView setHidden:NO];
        }
        else{
            [self.noMatchImageView setHidden:YES];
        }
        return;
    }
    
    PasswordStrengthType type = [PasswordChecker checkPasswordStrength:self.password0.stringValue];
    if(type == PasswordStrengthTypeInacceptable)
    {
        [self.pwStrengthLevel setDoubleValue:0];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordInacceptable", @"password strength inacceptable");
        self.pwStrength.textColor = [NSColor redColor];
        self.imageView0.image = [NSImage imageNamed:@"warning_red_small"];
        [self.okButton0 setEnabled:NO];
    }
    else if(type == PasswordStrengthTypeWeak)
    {
        [self.pwStrengthLevel setDoubleValue:1];
        [self.pwStrengthLevel setHidden:NO];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordWeak", @"password strength weak");
        self.pwStrength.textColor = [NSColor colorWithCalibratedRed:1.0/255*194 green:1.0/255*194 blue:1.0/255*53 alpha:1];
        self.imageView0.image = [NSImage imageNamed:@"warning_red_small"];
        [self.okButton0 setEnabled:YES];
    }
    else if(type == PasswordStrengthTypeModerate)
    {
        [self.pwStrengthLevel setHidden:NO];
        [self.pwStrengthLevel setDoubleValue:2];
        self.pwStrength.textColor = [NSColor grayColor];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordModerate", @"password strength moderate");
        self.imageView0.image = [NSImage imageNamed:@"warning_small"];
        [self.okButton0 setEnabled:YES];
    }
    else
    {
        [self.pwStrengthLevel setHidden:NO];
        [self.pwStrengthLevel setDoubleValue:3];
        self.pwStrength.textColor = [NSColor greenColor];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordStrong", @"password strength strong");
        self.imageView0.image = [NSImage imageNamed:@"ok_small"];
        [self.okButton0 setEnabled:YES];
    }
}

- (IBAction)continuePage0:(id)sender
{
    [self showPageWithNumber:1];
    [self.password1 becomeFirstResponder];
}

- (IBAction)continuePage1:(id)sender
{
    if(self.processFinished) {
        return;
    }
    
    if([self.password0.stringValue isEqualToString:self.password1.stringValue])
    {
        // okay, set encryption
        [self.noMatchImageView setHidden:YES];
        [self showPageWithNumber:2];
        
        [self.delegate performSelector:@selector(shouldPerformEncryption:) withObject:self.password0.stringValue];
        self.processFinished = YES;
    }
    else{
        // password did not match
        self.noMatchImageView.image = [NSImage imageNamed:@"error"];
        [self.noMatchImageView setHidden:NO];
    }
}

- (IBAction)closeSuccessful:(id)sender
{
    [self performClose:self];
}

- (IBAction)abort:(id)sender
{
    if(sender == self.abortButton0)
    {
        [self performClose:self];
    }
    else
    {
        [self showPageWithNumber:0];
    }
}

- (void)popoverWillShow:(NSNotification *)notification
{
    self.password0.stringValue = @"";
    self.password1.stringValue = @"";
    self.processFinished = NO;
    
    // make password become active
    [self.password0 becomeFirstResponder];
    
    [self.scrollView setDocumentView:self.containerView];
}

@end
