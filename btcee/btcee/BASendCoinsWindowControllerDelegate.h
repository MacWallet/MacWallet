//
//  BASendCoinsWindowControllerDelegate.h
//  btcee
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BASendCoinsWindowController;

@protocol BASendCoinsWindowControllerDelegate <NSObject>
@required
- (NSInteger)prepareSendCoinsFromWindowController:(BASendCoinsWindowController *)windowController receiver:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis;

@optional
- (void)sendCoinsWindowControllerWillClose:(BASendCoinsWindowController *)windowController;

@end
