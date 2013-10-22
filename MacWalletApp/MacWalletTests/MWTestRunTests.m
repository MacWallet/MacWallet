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

@interface MWTestRunTests ()
@property (assign) CGPoint leftTop;
@property (assign) CGPoint menuOffset;
@property (assign) CGFloat menuWith;
@end

@implementation MWTestRunTests

- (void)runTests
{
    
    [NSThread sleepForTimeInterval:2.0f];
    
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    for (NSMutableDictionary* entry in (__bridge NSArray*)windowList)
    {
        NSString* ownerName = [entry objectForKey:(id)kCGWindowOwnerName];
        NSInteger ownerPID = [[entry objectForKey:(id)kCGWindowOwnerPID] integerValue];
        NSLog(@"%@:%ld", ownerName, ownerPID);
    }
    CFRelease(windowList);
    
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

    
    [self showQRCode];
    exit(1);
    
    [self runPreferences];
    [self runShowMenu];
    
//    // get menu width
//    NSMenuItem *item = [APPD performSelector:@selector(networkStatusMenuItem)];
//
//    NSStatusItem *statusItem2 = [APPD performSelector:@selector(statusItem)];
//    NSWindow *appWin2 = [statusItem2 valueForKey:@"window"];
//    NSView *view = appWin.contentView;
//    NSRect frame2 = appWin2.frame;
    

    [self runEncryptWallet];
    [self runDecryptWallet];
    
    [self runSendCoins];
}

- (void)runSendCoins
{
    _leftDUP(self.leftTop);
    _slp(.5f);
    _ss;
    
    _leftD(self.leftTop.x+self.menuOffset.x,self.leftTop.y+95+self.menuOffset.y);
    _slp(.1f);
    _leftU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+95+self.menuOffset.y);
    _slp(1.0f);
    _ss;

    _slp(.3f);
    _leftDU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+65);
    _slp(.3f);
    
    // enter address
    _tt(@"mk9tTCzAYZpas3gXatV52tnA63DEgngoq4");
    _slp(.1f);

    // enter amount
    _leftDU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+92);
    _tt(@"0.123456");
    _slp(.1f);
    _ss;

    // press prepare
    _leftDU(self.leftTop.x+80+self.menuOffset.x,self.leftTop.y+135);
    _slp(.3f);
    _ss;
    
    // press commit
    _leftDU(self.leftTop.x+80+self.menuOffset.x,self.leftTop.y+210);
    _slp(.3f);
    _ss;
    
    // press close
    _leftDU(self.leftTop.x+140+self.menuOffset.x,self.leftTop.y+335);
    _slp(.3f);
    _ss;
    
    
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
    // open menu
    _leftDUP(self.leftTop);
    _slp(.5f);
    
    // show wallet menu
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+75+self.menuOffset.y);
    _slp(0.5f);
    _ss;
    
    
    
    // select decrypt
    _mm(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+92+self.menuOffset.y);
    _slp(0.5f);
    _ss;
    
    _slp(0.5f);
    _leftDU(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+92+self.menuOffset.y);
    _slp(1.5f);
    _tt(@"test");
    _slp(0.5f);
    _ss;
    _enter;
    
    _slp(1.5f);
    _leftDU(self.leftTop.x+100,self.leftTop.y+122);
}

- (void)runEncryptWallet
{
    // open menu
    _leftDUP(self.leftTop);
    _slp(0.5f);
    
    // show wallet menu
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+75+self.menuOffset.y);
    _slp(0.5f);
    _ss;
    
    // select encrypt
    _mm(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+76+self.menuOffset.y);
    _slp(0.5);
    _ss;
    
    // select encrypt
    _leftDU(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+76+self.menuOffset.y);
    _slp(1.5f);
    _ss;
    
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

    _leftDU(self.leftTop.x+85,self.leftTop.y+122);
    _slp(0.5f);
    _ss;
    _slp(0.5f);
    _leftDU(self.leftTop.x+85,self.leftTop.y+122);
}

- (void)runPreferences
{
    [APPD performSelectorOnMainThread:@selector(showPreferences:) withObject:self waitUntilDone:YES];
    _slp(.5f);
    
    RHPreferencesWindowController *winC = [APPD performSelector:@selector(preferencesWindowController)];
    NSWindow *win = winC.window;
    CGRect frame = win.frame;
    
    CGRect screenFrame = [NSScreen mainScreen].frame;
    
    frame.origin.y = screenFrame.size.height-frame.origin.y-frame.size.height;
    self.screenshotSize = frame;
    _ss;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        winC.selectedIndex = 1;
    });

    _slp(1.0f);
    _ss;
}

- (void)showQRCode
{
    _leftDUP(self.leftTop);
    _slp(.5f);
    
    // show addresses
    _mm(self.leftTop.x+self.menuOffset.x,self.leftTop.y+40+self.menuOffset.y);
    _slp(.5f);
    
    // select address
    _mm(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+40+self.menuOffset.y);
    _slp(0.5);
    
    // select address
    _leftDU(self.leftTop.x+self.menuOffset.x+self.menuWith,self.leftTop.y+40+self.menuOffset.y);
    _slp(1.5f);
    _ss;
    _slp(0.2f);
    
    _leftDU(self.leftTop.x+self.menuOffset.x,self.leftTop.y+325);
    _slp(0.5f);
    _leftDU(self.leftTop.x+self.menuOffset.x+90.0,self.leftTop.y+325);
}



@end
