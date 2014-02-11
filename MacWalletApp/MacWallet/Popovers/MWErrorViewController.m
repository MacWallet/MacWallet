//
//  MWErrorViewController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 03.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import "MWErrorViewController.h"

@interface MWErrorViewController ()
@property (assign) IBOutlet NSTextField *textLabel;
@property (assign) IBOutlet NSButton *closeButton;
@end

@implementation MWErrorViewController

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
    
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 311, 144);
}

- (IBAction)closePressed:(id)sender
{
    [self.popover performClose:self];
}

@end
