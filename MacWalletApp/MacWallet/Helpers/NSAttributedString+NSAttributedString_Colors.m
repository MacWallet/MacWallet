//
//  NSAttributedString+NSAttributedString_Colors.m
//  MacWallet
//
//  Created by Jonas Schnelli on 05.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import "NSAttributedString+NSAttributedString_Colors.h"

@implementation NSAttributedString (NSAttributedString_Colors)

+ (NSAttributedString *)attributedStringWithString:(NSString *)aString fontSize:(CGFloat)fontSize color:(NSColor *)color
{
    NSFont *font = [NSFont systemFontOfSize:fontSize];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:aString attributes:attrsDictionary];
    
    [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,string.length)];
    return string;
}

@end
