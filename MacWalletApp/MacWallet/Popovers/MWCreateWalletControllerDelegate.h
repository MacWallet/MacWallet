//
//  MWCreateWalletControllerDelegate.h
//  MacWallet
//
//  Created by Jonas Schnelli on 10.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HIPasswordHolder.h"

@class MWCreateWalletController;
@protocol MWCreateWalletControllerDelegate <NSObject>

- (void)walletController:(MWCreateWalletController *)walletController wantsToCreateWalletWithPassword:(HIPasswordHolder *)passwordHolder;

@end
