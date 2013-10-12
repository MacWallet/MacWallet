//
//  main.m
//  MacWallet
//
//  Created by Jonas Schnelli on 18.09.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    // make sure only one instance is running
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 0) {
        [NSApp terminate:nil];
    }
    
    return NSApplicationMain(argc, (const char **)argv);
}
