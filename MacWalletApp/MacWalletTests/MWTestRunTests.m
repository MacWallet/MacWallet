//
//  MWTestRunTests.m
//  MacWallet
//
//  Created by Jonas Schnelli on 17.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWTestRunTests.h"
#import "MWAppDelegate.h"
#import <CoreGraphics/CoreGraphics.h>
#import "RHPreferencesWindowController.h"
#import <BitcoinJKit/BitcoinJKit.h>


#define APPD ((MWAppDelegate *)[NSApp delegate])
#define _tt(x) [self typeText:(x)]
#define _ss [self takeScreenshot:-1]
#define _leftDU(x,y) [self leftClickDownUp:CGPointMake(x,y)]
#define _leftDUP(x) [self leftClickDownUp:x]
#define _leftD(x,y) [self leftClickDownUp:CGPointMake(x,y)]
#define _leftU(x,y) [self leftClickUp:CGPointMake(x,y)]
#define _mm(x,y) [self moveMouse:CGPointMake(x,y)]
#define _slp(x) [NSThread sleepForTimeInterval:x]
#define _enter [self sendEnter]
#define _tab [self sendTab]
#define _bspace [self sendBackspace]

@interface MWTestRunTests ()
@property (assign) CGPoint leftTop;
@property (assign) CGPoint menuOffset;
@property (assign) CGFloat menuWith;
@property (strong) NSString *firstAddress;
@property (strong) NSMutableString *screenshotMarkdown;
@end

@implementation MWTestRunTests

- (void)runTests
{
    self.screenshotMarkdown = [[NSMutableString alloc] init];
    
    
    NSArray *langs = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    self.language =[langs objectAtIndex:0];
    [self.screenshotMarkdown appendFormat:@"**Language: %@, time: %@\n", [langs objectAtIndex:0] ,[NSDate date]];
    
    [NSThread sleepForTimeInterval:2.0f];
    
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    for (NSMutableDictionary* entry in (__bridge NSArray*)windowList)
    {
        NSString* ownerName = [entry objectForKey:(id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
        NSLog(@"%@:%ld", ownerName, ownerPID);
    }
    CFRelease(windowList);
    


    [self setOffsetAndSizes];
    [self showQRCode];

    [self setOffsetAndSizes];
    [self runPreferences];

    [self setOffsetAndSizes];
    [self runShowMenu];
    
    _slp(0.3f);
    
    [self setOffsetAndSizes];
    [self runEncryptWallet];
    
    [self setOffsetAndSizes];
    [self runDecryptWallet];

    [self setOffsetAndSizes];
    [self runSendCoins];
    
    [self setOffsetAndSizes];
    [self showCoinsReceived];
    
    NSLog(@"%@", self.screenshotMarkdown);
}

- (void)setOffsetAndSizes
{
    NSStatusItem *statusItem = [APPD performSelector:@selector(statusItem)];
    NSWindow *appWin = [statusItem valueForKey:@"window"];
    NSRect frame = appWin.frame;
    
    self.leftTop = CGPointMake(frame.origin.x+10,1);
    self.menuOffset = CGPointMake(0, 0);
    self.screenshotSize = CGRectMake(self.leftTop.x-300, 0, 800,600);
    
    NSMenuItem *balanceUnconfirmedMenuItem = [APPD performSelector:@selector(balanceUnconfirmedMenuItem)];
    if(balanceUnconfirmedMenuItem.isHidden == NO)
    {
        self.menuOffset = CGPointMake(self.menuOffset.x, 20.0);
    }
    
    self.menuWith = 250.0;
}

- (void)runSendCoins
{
    [APPD performSelector:@selector(openSendCoins:) withObject:self];
    _slp(1.0f);
    _leftDU(self.leftTop.x,self.leftTop.y+50);
    _slp(.5f);
    _ss;
    
    // enter address
    _tt(@"mk9tTCzAYZpas3gXatV52tnA63DEgngoq4");
    _slp(.1f);

    // enter amount
    _tab;
    _tt(@"100000");
    _slp(.1f);
    _ss;
    
    // press prepare
    MWSendCoinsViewController *sendCoins = (MWSendCoinsViewController *)[APPD performSelector:@selector(sendCoinsWindowController)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [sendCoins performSelector:@selector(prepareClicked:) withObject:self];
    });
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    _bspace;
    _bspace;
    _bspace;
    _bspace;
    _bspace;
    _bspace;
    _slp(.5f);
    _tt(@"0.123456");
    _slp(.5f);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [sendCoins performSelector:@selector(prepareClicked:) withObject:self];
    });
    _slp(0.5f);
    _ss;
    _slp(.1f);
    
    // press commit
    dispatch_async(dispatch_get_main_queue(), ^{
        [sendCoins performSelector:@selector(commitClicked:) withObject:self];
    });
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    // press close
    dispatch_async(dispatch_get_main_queue(), ^{
        [sendCoins performSelector:@selector(closeClicked:) withObject:self];
    });
    _slp(.5f);
    _ss;
    _slp(.1f);
}

- (void)runShowMenu
{
    _leftDUP(self.leftTop);
    _slp(.5f);
    _ss;
  
    // show addresses
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+40+self.menuOffset.y);
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    // show transactions
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+56+self.menuOffset.y);
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    // show wallet
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+72+self.menuOffset.y);
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    // show network
    _mm(self.leftTop.x+140+self.menuOffset.x,self.leftTop.y+125+self.menuOffset.y);
    _slp(.5f);
    _ss;
    _slp(.1f);
    
    // disable menu
    
    _leftDUP(self.leftTop);
    _slp(.3f);
}

- (void)runDecryptWallet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [APPD performSelector:@selector(removeWalletEncryption:) withObject:self];
    });
    
    NSObject *popover = [APPD performSelector:@selector(enterPasswordPopover)];
    _slp(1.0f);
    _leftDU(self.leftTop.x,self.leftTop.y+50);
    _slp(.5f);
    _ss;
    _slp(0.1f);
    
    _tt(@"test");
    _slp(0.5f);
    _ss;
    _enter;
    _slp(1.0f);
    _ss;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [popover performSelector:@selector(performClose:) withObject:self];
    });
    
    _slp(1.0f);
}

- (void)runEncryptWallet
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [APPD performSelector:@selector(encryptWallet:) withObject:self];
    });
    
    NSObject *popover = [APPD performSelector:@selector(choosePasswordPopover)];
    
    _slp(1.0f);
    _leftDU(self.leftTop.x,self.leftTop.y+50);
    _slp(.5f);
    _ss;
    _slp(0.1f);
    
    // enter first password
    _tt(@"test");
    _slp(0.5f);
    _ss;
    _enter;
    _slp(0.5f);
    _ss;
    
    //enter 2nd password
    _tt(@"test");
    _slp(0.5f);
    _ss;
    _enter;
    _slp(0.5f);
    _ss;
    _slp(0.5f);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [popover performSelector:@selector(closeSuccessful:) withObject:self];
    });
    
    _slp(1.0f);
}

- (void)runPreferences
{
    [APPD performSelectorOnMainThread:@selector(showPreferences:) withObject:self waitUntilDone:YES];
    _slp(.3f);
    
    RHPreferencesWindowController *winC = [APPD performSelector:@selector(preferencesWindowController)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        winC.selectedIndex = 0;
    });
    _slp(.3f);
    
    NSWindow *win = winC.window;
    CGRect frame = win.frame;
    
    CGRect screenFrame = [NSScreen mainScreen].frame;
    
    frame.origin.y = screenFrame.size.height-frame.origin.y-frame.size.height;
    self.screenshotSize = frame;
    _ss;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        winC.selectedIndex = 1;
    });
    _slp(0.3f);

    frame = win.frame;
    frame.origin.y = screenFrame.size.height-frame.origin.y-frame.size.height;
    self.screenshotSize = frame;

    _slp(0.3f);
    _ss;
    dispatch_async(dispatch_get_main_queue(), ^{
        [winC.window close];
    });
    _slp(0.3f);
}

- (void)showQRCode
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.firstAddress = [[HIBitcoinManager defaultManager].allWalletAddresses objectAtIndex:0];
        [APPD performSelector:@selector(showDetailsForAddress:) withObject:self.firstAddress];
    });
    _slp(.5f);
    _ss;

    _leftDU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+345);
    _slp(0.5f);
    
    _leftDU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+370);
    _slp(0.5f);
    
    _leftDU(self.leftTop.x+self.menuOffset.x+100.0,self.leftTop.y+370);
}

- (void)showCoinsReceived
{
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL showPopup = [[NSUserDefaults standardUserDefaults] boolForKey:kSHOW_POPUP_INCOMING_FUNDS];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSHOW_POPUP_INCOMING_FUNDS];
        _slp(0.5f);
        
        [APPD performSelector:@selector(demoCoinsAction)];
        _slp(1.0f);
        [[NSUserDefaults standardUserDefaults] setBool:showPopup forKey:kSHOW_POPUP_INCOMING_FUNDS];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _slp(0.5f);
    });
    _slp(1.0f);
    _ss;
    _slp(0.5f);
}

- (void)takeScreenshot:(NSInteger)num
{
    [self.screenshotMarkdown appendFormat:@"![Screenshot %ld](http://macwallet.github.io/screenshots/auto/%@/%ld.png)\n", self.currentScreenshotNum, self.language, self.currentScreenshotNum];
    [super takeScreenshot:num];
}

@end