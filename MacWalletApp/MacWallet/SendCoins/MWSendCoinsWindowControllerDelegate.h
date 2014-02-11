//
//  BASendCoinsWindowControllerDelegate.h
//  MacWallet
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BitcoinJKit/BitcoinJKit.h>

@class MWSendCoinsViewController;

@protocol MWSendCoinsWindowControllerDelegate <NSObject>
@required
- (nanobtc_t)prepareSendCoinsFromWindowController:(MWSendCoinsViewController *)windowController receiver:(NSString *)btcAddress amount:(nanobtc_t)amountInSatoshis txfee:(nanobtc_t)txFeeInSatoshis password:(NSData *)passwordData error:(NSError **)error;

@optional
- (void)sendCoinsWindowControllerWillClose:(MWSendCoinsViewController *)windowController;

@end
