//
//  MWQRCodeViewController.m
//  MacWallet
//
//  Created by Jonas Schnelli on 21.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWAddressDetailViewController.h"
#import "QREncoder.h"

@interface MWAddressDetailViewController ()
@property (assign) IBOutlet NSButton *qrCodeButton;
@property (assign) IBOutlet NSButton *pasteboardCopyAddressButton;
@property (assign) IBOutlet NSButton *pasteboardCopyImageButton;
@property (assign) IBOutlet NSButton *closeButton;
@property (assign) IBOutlet NSTextField *addressLabel;
@end

@implementation MWAddressDetailViewController

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
    self.qrCodeButton.image = [self generateQRCodeFromAddress:self.addressToShow];

    // i18n
    self.pasteboardCopyAddressButton.title = NSLocalizedString(@"copyAddressButton", @"show address copy to clipboard button");
    self.pasteboardCopyImageButton.title = NSLocalizedString(@"copyImageButton", @"show address copy image to clipboard button");
    self.closeButton.title = NSLocalizedString(@"closeButton", @"show address close button");
    self.addressLabel.stringValue = self.addressToShow;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeButton:)
                                                 name:kSHOULD_CLOSE_OPEN_POPUPS_NOTIFICATION
                                               object:nil];
}

#pragma mark - QRCode Stack

- (NSImage *)generateQRCodeFromAddress:(NSString *)address
{
    DataMatrix *matrix = [QREncoder encodeWithECLevel:1 version:1 string:address];
    int qrcodeImageDimension = 250;
    return [QREncoder renderDataMatrix:matrix imageDimension:qrcodeImageDimension];
}

#pragma mark - Actions Stack

- (IBAction)closeButton:(id)sender
{
    [self.popover performClose:self];
}

- (IBAction)copyAddress:(id)sender
{
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [[NSPasteboard generalPasteboard] setString:self.addressToShow forType:NSStringPboardType];
}

- (IBAction)copyImage:(id)sender
{
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithObject:self.qrCodeButton.image]];
}

@end
