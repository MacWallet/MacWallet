//
//  NSStatusItem+NSStatusItem_i7MultipleMenuBarSupport.m
//  MacWallet
//
//  Created by Jonas Schnelli on 10.02.14.
//  Copyright (c) 2014 include7 AG. All rights reserved.
//

#import "NSStatusItem+NSStatusItem_i7MultipleMenuBarSupport.h"

@implementation NSStatusItem (NSStatusItem_i7MultipleMenuBarSupport)

- (NSWindow *)statusMenuItemWindowOnMainScreen
{
    NSWindow *appWin = [self valueForKey:@"window"];
    
    if([appWin screen] != [NSScreen mainScreen])
    {
        NSDictionary *possibleReplicants = [self valueForKey:@"replicants"];
        if(possibleReplicants && [possibleReplicants isKindOfClass:[NSDictionary class]])
        {
            if([possibleReplicants allKeys].count > 0) {
                NSObject *obj = [possibleReplicants objectForKey:[[possibleReplicants allKeys] objectAtIndex:0]];
                if(obj)
                {
                    NSWindow *appWin2 = [obj valueForKey:@"window"];
                    if(appWin2)
                    {
                        if([appWin2 screen] == [NSScreen mainScreen])
                        {
                            // this could be the icon
                            appWin = appWin2;
                        }
                    }
                }
            }
            
        }
    }
    
    return appWin;
}

@end
