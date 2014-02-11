//
//  NSAttributedString+NSAttributedString_Colors.h
//  MacWallet
//
//  Created by Jonas Schnelli on 05.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (NSAttributedString_Colors)

+ (NSAttributedString *)attributedStringWithString:(NSString *)aString fontSize:(CGFloat)fontSize color:(NSColor *)color;

@end
