//
//  MWFundsReceivedViewController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 21.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWFundsReceivedViewController.h"

@interface MWFundsReceivedViewController ()
@property (assign) IBOutlet NSTextField *textLabel;
@property (assign) IBOutlet NSButton *closeButton;
@end

@implementation MWFundsReceivedViewController

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
    // i18n
    self.textLabel.stringValue = self.textToShow;
    self.closeButton.title = NSLocalizedString(@"closeButton", @"");
}

- (IBAction)closePressed:(id)sender
{
    [self.popover performClose:self];
}

@end
