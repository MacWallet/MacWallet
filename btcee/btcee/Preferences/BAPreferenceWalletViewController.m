//
//  BAPreferenceWalletViewController.m
//  btcee
//
//  Created by Jonas Schnelli on 03.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BAPreferenceWalletViewController.h"

@interface BAPreferenceWalletViewController ()
@property IBOutlet NSButton *useKeychainAsWalletStoreCheckbox;
@property IBOutlet NSButton *keepBackupfileCheckbox;
@end

@implementation BAPreferenceWalletViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    // todo: localization stuff
    
    [[NSUserDefaults standardUserDefaults] boolForKey:kUSE_KEYCHAIN_KEY] ? [self.keepBackupfileCheckbox setEnabled:YES] : [self.keepBackupfileCheckbox setEnabled:NO];
}


#pragma mark - custom stuff

- (BOOL)useKeychain
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUSE_KEYCHAIN_KEY];
}

- (void)setUseKeychain:(BOOL)aState
{
    aState ? [self.keepBackupfileCheckbox setEnabled:YES] : [self.keepBackupfileCheckbox setEnabled:NO];

    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kUSE_KEYCHAIN_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier
{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage
{
    return [NSImage imageNamed:@"wallet"];
}
-(NSString*)toolbarItemLabel
{
    return NSLocalizedString(@"Wallet", @"GeneralToolbarItemLabel");
}

-(NSView*)initialKeyView
{
    return nil;
}

@end
