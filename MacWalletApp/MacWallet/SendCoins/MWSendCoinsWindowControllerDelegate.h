//
//  BASendCoinsWindowControllerDelegate.h
//  MacWallet
//
//  Created by Jonas Schnelli on 25.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWSendCoinsWindowController;

@protocol MWSendCoinsWindowControllerDelegate <NSObject>
@required
- (NSInteger)prepareSendCoinsFromWindowController:(MWSendCoinsWindowController *)windowController receiver:(NSString *)btcAddress amount:(NSInteger)amountInSatoshis txfee:(NSInteger)txFeeInSatoshis password:(NSString *)password;

@optional
- (void)sendCoinsWindowControllerWillClose:(MWSendCoinsWindowController *)windowController;

@end
