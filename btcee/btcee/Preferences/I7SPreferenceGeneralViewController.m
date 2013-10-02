//
//  I7SPreferenceSharesViewController.m
//  i7share
//
//  Created by Jonas Schnelli on 30.07.12.
//  Copyright (c) 2012 include7 AG. All rights reserved.
//

#import "I7SPreferenceGeneralViewController.h"
#import "BAAppDelegate.h"

@interface I7SPreferenceGeneralViewController ()
@property (assign) IBOutlet NSButton *checkUpdatesAtStartup;
@property (assign) IBOutlet NSButton *autostartSystem;
@property (assign) IBOutlet NSTextField *currencyLabel;
@property (assign) IBOutlet NSComboBox *currencySelector;
@property (assign) IBOutlet NSComboBox *updateIntervalBox;
@end

@implementation I7SPreferenceGeneralViewController
@synthesize currencySelector=_currencySelector;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - custom stuff


- (BOOL)launchAtStartup {
    BAAppDelegate *dele = (BAAppDelegate *)[NSApplication sharedApplication].delegate;
    return dele.launchAtStartup;
    return YES;
}

- (void)setLaunchAtStartup:(BOOL)aState {
    BAAppDelegate *dele = (BAAppDelegate *)[NSApplication sharedApplication].delegate;
    dele.launchAtStartup = aState;
}


#pragma mark - View hide/show

- (void)awakeFromNib {
    [self.currencySelector addItemsWithObjectValues:[NSArray arrayWithObjects:NSLocalizedString(@"BSCurrencyUSD", @"usd currency string"), NSLocalizedString(@"BSCurrencyEUR", @"EUR currency string"), NSLocalizedString(@"BSCurrencyCHF", @"CHF currency string"), NSLocalizedString(@"BSCurrencyGBP", @"GBP currency string"), nil]];
    [self.currencySelector selectItemAtIndex:0];
    NSString *currency = [[NSUserDefaults standardUserDefaults] objectForKey:BSUserDefaultsCurrencyKey];
    if(currency) {
        if([currency isEqualToString:@"EUR"]) {
            [self.currencySelector selectItemAtIndex:1];
        }
        if([currency isEqualToString:@"CHF"]) {
            [self.currencySelector selectItemAtIndex:2];
        }
        if([currency isEqualToString:@"GBP"]) {
            [self.currencySelector selectItemAtIndex:3];
        }
    }
    self.currencySelector.delegate = self;
    
    [self.updateIntervalBox addItemsWithObjectValues:[NSArray arrayWithObjects:NSLocalizedString(@"10 sec", @"10 sec preference value"), NSLocalizedString(@"30 sec", @"30 sec preference value"), NSLocalizedString(@"1 min", @"1 min preference value"), NSLocalizedString(@"2 min", @"2 min preference value"), NSLocalizedString(@"5 min", @"5 min preference value"), NSLocalizedString(@"10 min", @"10 min preference value"), NSLocalizedString(@"30 min", @"30 min preference value"), NSLocalizedString(@"1 h", @"1 h preference value"),nil]];
    [self.updateIntervalBox selectItemAtIndex:3];
    NSNumber *updateIntervalNumber = [[NSUserDefaults standardUserDefaults] objectForKey:BSUserDefaultsUpdateIntervalKey];
    if(updateIntervalNumber) {
        if([updateIntervalNumber intValue] == 10) {
            [self.updateIntervalBox selectItemAtIndex:0];
        }
        else if([updateIntervalNumber intValue] == 30) {
            [self.updateIntervalBox selectItemAtIndex:1];
        }
        else if([updateIntervalNumber intValue] == 60) {
            [self.updateIntervalBox selectItemAtIndex:2];
        }
        else if([updateIntervalNumber intValue] == 60*2) {
            [self.updateIntervalBox selectItemAtIndex:3];
        }
        else if([updateIntervalNumber intValue] == 60*5) {
            [self.updateIntervalBox selectItemAtIndex:4];
        }
        else if([updateIntervalNumber intValue] == 60*30) {
            [self.updateIntervalBox selectItemAtIndex:5];
        }
        else if([updateIntervalNumber intValue] == 60*60) {
            [self.updateIntervalBox selectItemAtIndex:6];
        }
    }
    self.updateIntervalBox.delegate = self;
    
    self.checkUpdatesAtStartup.title = NSLocalizedString(@"Check for updates at startup", @"check for update preference button text");
    self.autostartSystem.title = NSLocalizedString(@"Automatically launch BitcoinStatus at startup", @"auto check updates preference button text");
    self.currencyLabel.stringValue = NSLocalizedString(@"Currency", @"currency preference combo box");
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if(notification.object == self.currencySelector) {
        if(self.currencySelector.indexOfSelectedItem == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@"USD" forKey:BSUserDefaultsCurrencyKey];
        }
        else if(self.currencySelector.indexOfSelectedItem == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:@"EUR" forKey:BSUserDefaultsCurrencyKey];
        }
        else if(self.currencySelector.indexOfSelectedItem == 2) {
            [[NSUserDefaults standardUserDefaults] setObject:@"CHF" forKey:BSUserDefaultsCurrencyKey];
        }
        else if(self.currencySelector.indexOfSelectedItem == 3) {
            [[NSUserDefaults standardUserDefaults] setObject:@"GBP" forKey:BSUserDefaultsCurrencyKey];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:BSShouldReloadFromRemoteNotification object:nil];
    }
    else if(notification.object == self.updateIntervalBox) {
        if(self.updateIntervalBox.indexOfSelectedItem == 0) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:10] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:30] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 2) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:60] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 3) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:60*2] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 4) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:60*5] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 5) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:60*30] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        else if(self.updateIntervalBox.indexOfSelectedItem == 5) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:60*60] forKey:BSUserDefaultsUpdateIntervalKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:BSShouldResetTimerNotification object:nil];
    }

    
}


- (void)viewDidDisappear {
    
    
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}
-(NSString*)toolbarItemLabel{
    
    return NSLocalizedString(@"General", @"GeneralToolbarItemLabel");
}

-(NSView*)initialKeyView{
    return nil;
}


@end
