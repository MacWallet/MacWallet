//
//  MWBasePopover.m
//  MacWallet
//
//  Created by Jonas Schnelli on 14.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "MWBasePopover.h"
#import "DuxScrollViewAnimation.h"

@implementation MWBasePopover

- (NSScrollView *)scrollView
{
    return nil;
}

- (void)showPageWithNumber:(int)page
{
    [DuxScrollViewAnimation animatedScrollToPoint:NSMakePoint(230*page,0) inScrollView:self.scrollView];
}

@end
