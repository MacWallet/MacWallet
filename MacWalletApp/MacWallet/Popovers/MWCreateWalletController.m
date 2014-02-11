//
//  MWCreateWalletController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 05.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import "MWCreateWalletController.h"
#import "passwordChecker.h"
#import "NSPopover+NSPopover_MWPopoverAddOn.h"

@interface MWCreateWalletController ()
@property (assign) IBOutlet NSSecureTextField *password;
@property (assign) IBOutlet NSTextField *passwordLabel;
@property (assign) IBOutlet NSSecureTextField *passwordCheck;
@property (assign) IBOutlet NSTextField *passwordCheckLabel;
@property (assign) IBOutlet NSButton *enableEncryptionButton;
@property (assign) IBOutlet NSButton *enableiCloudBackups;
@property (assign) IBOutlet NSBox *encryptionBox;
@property (assign) IBOutlet NSBox *backupBox;
@property (assign) IBOutlet NSButton *okayButton;
@property (assign) IBOutlet NSButton *cancelButton;
@property (assign) IBOutlet NSTextField *introText;
@property (assign) IBOutlet NSImageView *noMatchImageView;
@property (assign) IBOutlet NSImageView *passwordImageView;
@property (assign) IBOutlet NSLevelIndicator *pwStrengthLevel;
@property (assign) IBOutlet NSTextField *pwStrength;
@property (assign) IBOutlet NSTextField *backupNotAllowedText;

@property (assign) BOOL encryption;

@end

@implementation MWCreateWalletController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.encryption = YES;
    }
    return self;
}

-(void)awakeFromNib
{
    // set i18n
    [self setEnableViewState:YES];
}

- (void)setEnableEncryption:(BOOL)enableEncryption
{
    [self setEnableViewState:enableEncryption];
    self.encryption = enableEncryption;
}

- (BOOL)enableEncryption
{
    return self.encryption;
}

- (void)setEnableViewState:(BOOL)aState
{
    [self.password setEnabled:aState];
    [self.passwordLabel setEnabled:aState];
    [self.passwordCheck setEnabled:aState];
    [self.passwordCheckLabel setEnabled:aState];
    
    [self.pwStrengthLevel setEnabled:aState];
    [self.passwordImageView setEnabled:aState];
    [self.noMatchImageView setEnabled:aState];
    
    NSColor *textColor = (!aState) ? [NSColor grayColor] : [NSColor blackColor];
    self.passwordLabel.textColor = textColor;
    self.passwordCheckLabel.textColor = textColor;
    
    [self.enableiCloudBackups setEnabled:aState];
    [self.backupNotAllowedText setHidden:aState];
}

-(void)controlTextDidChange:(NSNotification *)notification {
    
    if(notification.object == self.passwordCheck)
    {
        if([self.password.stringValue isEqualToString:self.passwordCheck.stringValue])
        {
            self.noMatchImageView.image = [NSImage imageNamed:@"ok_small"];
            [self.noMatchImageView setHidden:NO];
        }
        else{
            [self.noMatchImageView setHidden:YES];
        }
        return;
    }
    
    PasswordStrengthType type = [PasswordChecker checkPasswordStrength:self.password.stringValue];
    if(type == PasswordStrengthTypeInacceptable)
    {
        [self.pwStrengthLevel setDoubleValue:0];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordInacceptable", @"password strength inacceptable");
        self.pwStrength.textColor = [NSColor redColor];
        self.passwordImageView.image = [NSImage imageNamed:@"warning_red_small"];
    }
    else if(type == PasswordStrengthTypeWeak)
    {
        [self.pwStrengthLevel setDoubleValue:1];
        [self.pwStrengthLevel setHidden:NO];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordWeak", @"password strength weak");
        self.pwStrength.textColor = [NSColor colorWithCalibratedRed:1.0/255*194 green:1.0/255*194 blue:1.0/255*53 alpha:1];
        self.passwordImageView.image = [NSImage imageNamed:@"warning_red_small"];
    }
    else if(type == PasswordStrengthTypeModerate)
    {
        [self.pwStrengthLevel setHidden:NO];
        [self.pwStrengthLevel setDoubleValue:2];
        self.pwStrength.textColor = [NSColor grayColor];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordModerate", @"password strength moderate");
        self.passwordImageView.image = [NSImage imageNamed:@"warning_small"];
    }
    else
    {
        [self.pwStrengthLevel setHidden:NO];
        [self.pwStrengthLevel setDoubleValue:3];
        self.pwStrength.textColor = [NSColor greenColor];
        self.pwStrength.stringValue = NSLocalizedString(@"passwordStrong", @"password strength strong");
        self.passwordImageView.image = [NSImage imageNamed:@"ok_small"];
    }
}

- (IBAction)cancelPressed:(id)sender
{
    [self.popover performClose:self];
}

- (IBAction)okPressed:(id)sender
{

    if(!self.encryption)
    {
        NSInteger retVal = [self.popover showError:NSLocalizedString(@"questionIfcontinueWithoutEncryption", @"question if the user like to continue without encryption") continueOption:YES];
        
        if(retVal != NSAlertFirstButtonReturn)
        {
            // cancel pressed
            return;
        }

    }
    
    PasswordStrengthType type = [PasswordChecker checkPasswordStrength:self.password.stringValue];
    
    if(self.encryption && ![self.password.stringValue isEqualToString:self.passwordCheck.stringValue])
    {
        [self.popover showError:NSLocalizedString(@"passwordDontMatch", @"error text when password does not match") continueOption:NO];
        return;
    }
    else if(self.encryption && type == PasswordStrengthTypeInacceptable)
    {
        [self.popover showError:NSLocalizedString(@"passwordIsInacceptable", @"passwordIsInacceptable") continueOption:NO cancelButton:NSLocalizedString(@"Ok", @"Okay Button")];
        return;
    }
    else if(self.encryption && type != PasswordStrengthTypeModerate && type != PasswordStrengthTypeStrong)
    {
        NSInteger retVal = [self.popover showError:NSLocalizedString(@"passwordIsWeak", @"passwordIsWeak") continueOption:YES];
        if(retVal != NSAlertFirstButtonReturn)
        {
            // cancel pressed
            return;
        }
    }
    
    NSInteger retVal = [self.popover showError:NSLocalizedString(@"warnForPasswordLost", @"Warning text to reminde user to not forget the wallet password") continueOption:NO cancelButton:NSLocalizedString(@"Ok", @"Okay Button")];
    
    HIPasswordHolder *passwordHolder = nil;
    
    if(self.encryption) {
        passwordHolder = [[HIPasswordHolder alloc] initWithString:self.password.stringValue];
    }
    
    [self.delegate walletController:self wantsToCreateWalletWithPassword:passwordHolder];
    [passwordHolder clear];
    
    // create wallet
    [self.popover performClose:self];
}

@end
