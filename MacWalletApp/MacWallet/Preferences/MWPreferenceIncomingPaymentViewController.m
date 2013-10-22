//
//  MWPreferenceIncomingPaymentViewController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 17.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWPreferenceIncomingPaymentViewController.h"

@interface MWPreferenceIncomingPaymentViewController ()
@property (assign) IBOutlet NSButtonCell *showNotificationCheckbox;
@property (assign) IBOutlet NSButtonCell *showPopupCheckbox;
@property (assign) IBOutlet NSButtonCell *runScriptCheckbox;
@property (assign) IBOutlet NSTextField *runScriptPath;
@property (assign) IBOutlet NSButtonCell *playSoundCheckbox;
@property (assign) IBOutlet NSTextField *playSoundPath;
@end

@implementation MWPreferenceIncomingPaymentViewController

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
    NSString *soundPath = [[NSUserDefaults standardUserDefaults] objectForKey:kPLAY_SOUND_PATH_INCOMING_FUNDS];
    if(soundPath && [soundPath isKindOfClass:[NSString class]] && soundPath.length > 0)
    {
        self.playSoundPath.stringValue = soundPath;
    }

    NSString *scriptPath = [[NSUserDefaults standardUserDefaults] objectForKey:kRUN_SCRIPT_PATH_INCOMING_FUNDS];
    if(scriptPath && [scriptPath isKindOfClass:[NSString class]] && scriptPath.length > 0)
    {
        self.runScriptPath.stringValue = scriptPath;
    }

    if(!self.playSound)
    {
        [self.playSoundPath setEnabled:NO];
    }
    
    if(!self.runScript)
    {
        [self.runScriptPath setEnabled:NO];
    }
    
    // i18n
    
    self.showNotificationCheckbox.title = NSLocalizedString(@"incomingPaymentShowUserNotification", @"Show User Notification Preference Label");
    self.showPopupCheckbox.title        = NSLocalizedString(@"incomingPaymentShowPopup", @"Show Popup Notification Preference Label");
    self.playSoundCheckbox.title        = NSLocalizedString(@"incomingPaymentPlaySound", @"Play Sound Preference Label");
    self.runScriptCheckbox.title        = NSLocalizedString(@"incomingPaymentRunScript", @"Run Script Preference Label");

}

#pragma mark UserDefaults Bindings
- (BOOL)showNotification
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_NOTIFICATION_INCOMING_FUNDS];
}

- (void)setShowNotification:(BOOL)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kSHOW_NOTIFICATION_INCOMING_FUNDS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showPopup
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_POPUP_INCOMING_FUNDS];
}

- (void)setShowPopup:(BOOL)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kSHOW_POPUP_INCOMING_FUNDS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)runScript
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kRUN_SCRIPT_INCOMING_FUNDS];
}

- (void)setRunScript:(BOOL)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kRUN_SCRIPT_INCOMING_FUNDS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!aState)
    {
        [self.runScriptPath setEnabled:NO];
    }
    else
    {
        [self.runScriptPath setEnabled:YES];
    }
}

- (BOOL)playSound
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kPLAY_SOUND_INCOMING_FUNDS];
}

- (void)setPlaySound:(BOOL)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kPLAY_SOUND_INCOMING_FUNDS];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(!aState)
    {
        [self.playSoundPath setEnabled:NO];
    }
    else
    {
        [self.playSoundPath setEnabled:YES];
    }
}

#pragma mark Path Saving Stuff

- (IBAction)selectPathForSound:(id)sender
{
    if(!self.playSound)
    {
        return;
    }
    NSInteger result;
    NSOpenPanel *sPanel = [NSOpenPanel openPanel];
    sPanel.title = NSLocalizedString(@"selectSoundFile", @"Select Sound Dialog Title");
    result = [sPanel runModal];
    if (result == NSOKButton) {
        self.playSoundPath.stringValue = sPanel.URL.path;
        NSNotification *notification = [NSNotification notificationWithName:@"unknown" object:self.playSoundPath];
        [self controlTextDidChange:notification];
    }
}

- (IBAction)selectPathForScript:(id)sender
{
    if(!self.runScript)
    {
        return;
    }
    NSInteger result;
    NSOpenPanel *sPanel = [NSOpenPanel openPanel];
    sPanel.title = NSLocalizedString(@"selectSoundFile", @"Select Sound Dialog Title");
    result = [sPanel runModal];
    if (result == NSOKButton) {
        self.runScriptPath.stringValue = sPanel.URL.path;
        NSNotification *notification = [NSNotification notificationWithName:@"unknown" object:self.runScriptPath];
        [self controlTextDidChange:notification];
    }
}

#pragma mark - NSTextField Delegate

- (void)controlTextDidChange:(NSNotification *)notification
{
    if([notification object] == self.playSoundPath)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.playSoundPath.stringValue forKey:kPLAY_SOUND_PATH_INCOMING_FUNDS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if([notification object] == self.runScriptPath)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.runScriptPath.stringValue forKey:kRUN_SCRIPT_PATH_INCOMING_FUNDS];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier
{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage
{
    return [NSImage imageNamed:@"incoming_payment"];
}
-(NSString*)toolbarItemLabel
{
    return NSLocalizedString(@"preferencesIncomingPayment", @"Arriving Funds Preference Label");
}

-(NSView*)initialKeyView
{
    return nil;
}

@end
