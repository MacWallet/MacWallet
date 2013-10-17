//
//  I7SPreferenceSharesViewController.m
//  i7share
//
//  Created by Jonas Schnelli on 30.07.12.
//  Copyright (c) 2012 include7 AG. All rights reserved.
//

#import "MWPreferenceGeneralViewController.h"
#import "MWAppDelegate.h"
#import "MWTickerController.h"

@interface MWPreferenceGeneralViewController ()
@property (assign) IBOutlet NSButton *checkUpdatesAtStartup;
@property (assign) IBOutlet NSButton *autostartSystem;
@property (assign) IBOutlet NSButton *showTimeAgoButton;
@property (assign) IBOutlet NSTextField *tickerLabel;
@property (assign) IBOutlet NSComboBox *tickerSelector;

@property (assign) IBOutlet NSTextField *whatToShowLabel;
@property (assign) IBOutlet NSMatrix *radioButtonGroup;
@property (assign) IBOutlet NSButtonCell *showBalanceButton;
@property (assign) IBOutlet NSButtonCell *showTickerButton;
@property (assign) IBOutlet NSButtonCell *showBothButton;
@property (assign) BOOL showTimeAgo;
@end

@implementation MWPreferenceGeneralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - custom stuff

- (BOOL)launchAtStartup
{
    MWAppDelegate *dele = (MWAppDelegate *)[NSApplication sharedApplication].delegate;
    return dele.launchAtStartup;
    return YES;
}

- (void)setLaunchAtStartup:(BOOL)aState
{
    MWAppDelegate *dele = (MWAppDelegate *)[NSApplication sharedApplication].delegate;
    dele.launchAtStartup = aState;
}

- (BOOL)showTimeAgo
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_TIME_AGO_KEY];
}

- (void)setShowTimeAgo:(BOOL)aState
{
    [[NSUserDefaults standardUserDefaults] setBool:aState forKey:kSHOW_TIME_AGO_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHOULD_UPDATE_AFTER_PREFS_CHANGE_NOTIFICATION object:self];
}



#pragma mark - View hide/show

- (void)awakeFromNib {
    
    NSMutableArray *tickerLabels = [NSMutableArray array];
    NSDictionary *tickerDatabase = [MWTickerController defaultController].tickerDatabase;
    
    for(NSString *tickerLabel in [tickerDatabase allKeys])
    {
        [tickerLabels addObject:tickerLabel];
    }
    
    [self.tickerSelector addItemsWithObjectValues:tickerLabels];
    [self.tickerSelector selectItemAtIndex:0];
    NSString *selectedTicker = [[NSUserDefaults standardUserDefaults] objectForKey:kTICKER_NAME_KEY];

    int i = 0;
    for(i=0;i < self.tickerSelector.objectValues.count;i++)
    {
        if([[self.tickerSelector.objectValues objectAtIndex:i] isEqualToString:selectedTicker])
        {
            [self.tickerSelector selectItemAtIndex:i];
        }
    }
    
    self.tickerSelector.delegate = self;
    

    self.checkUpdatesAtStartup.title = NSLocalizedString(@"checkForUpdatesAtStartupLabel", @"check for update preference button text");
    self.autostartSystem.title      = NSLocalizedString(@"autostartPrefsLabel", @"auto check updates preference button text");
    self.tickerLabel.stringValue    = NSLocalizedString(@"tickerLabel", @"currency preference combo box");
    
    self.showBalanceButton.title    = NSLocalizedString(@"showBalanceButtonLabel", @"currency preference combo box");
    self.showTickerButton.title     = NSLocalizedString(@"showTickerButton", @"currency preference combo box");
    self.showBothButton.title       = NSLocalizedString(@"showBothButton", @"currency preference combo box");
    self.whatToShowLabel.stringValue= NSLocalizedString(@"whatToShowLabel", @"currency preference combo box");
    self.showTimeAgoButton.title     = NSLocalizedString(@"timeAgoLabel", @"timeAgoLabel label");
    
    
    NSInteger statusItemStyle = [[NSUserDefaults standardUserDefaults] integerForKey:kSTATUS_ITEM_STYLE_KEY];
    [self.radioButtonGroup selectCellWithTag:statusItemStyle];
    
    NSString *tickerKey = [[NSUserDefaults standardUserDefaults] objectForKey:kTICKER_NAME_KEY];
    if(tickerKey)
    {
        [self.tickerSelector selectItemWithObjectValue:tickerKey];
    }
    else {
        [self.tickerSelector selectItemWithObjectValue:kDEFAULT_TICKER_NAME];
    }
    
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
    if(notification.object == self.tickerSelector)
    {
        [[NSUserDefaults standardUserDefaults] setObject:self.tickerSelector.objectValueOfSelectedItem forKey:kTICKER_NAME_KEY];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSHOULD_UPDATE_AFTER_PREFS_CHANGE_NOTIFICATION object:self];
    }
}

- (IBAction)radioButtonMatrixDidChange:(id)sender
{
    // save statusmenu text style
    
    NSMatrix *matrix = (NSMatrix *)sender;
    NSCell *seletcedCell = [matrix selectedCell];
    [[NSUserDefaults standardUserDefaults] setInteger:seletcedCell.tag forKey:kSTATUS_ITEM_STYLE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSHOULD_UPDATE_AFTER_PREFS_CHANGE_NOTIFICATION object:self];
}

#pragma mark - RHPreferencesViewControllerProtocol

-(NSString*)identifier
{
    return NSStringFromClass(self.class);
}
-(NSImage*)toolbarItemImage
{
    return [NSImage imageNamed:@"settings"];
}
-(NSString*)toolbarItemLabel
{
    return NSLocalizedString(@"preferencesGeneral", @"GeneralToolbarItemLabel");
}
-(NSView*)initialKeyView
{
    return nil;
}


@end
