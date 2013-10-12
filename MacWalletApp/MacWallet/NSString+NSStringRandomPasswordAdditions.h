//
//  NSString+NSStringRandomPasswordAdditions.h
//  MacWallet
//
//  Created by Jonas Schnelli on 10.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringRandomPasswordAdditions)

+ (NSString *) passwordStringFromData:(NSData *)data length:(int)length;

@end