//
//  I7MacInterfaceAutomation.m
//  MacWallet
//
//  Created by Jonas Schnelli on 18.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "I7MacInterfaceAutomation.h"

@interface I7MacInterfaceAutomation()

@end
@implementation I7MacInterfaceAutomation




int keyCodeForKeyString(char * keyString)
{
	if (strcmp(keyString, "a") == 0) return 0;
	if (strcmp(keyString, "s") == 0) return 1;
	if (strcmp(keyString, "d") == 0) return 2;
	if (strcmp(keyString, "f") == 0) return 3;
	if (strcmp(keyString, "h") == 0) return 4;
	if (strcmp(keyString, "g") == 0) return 5;
	//if (strcmp(keyString, "z") == 0) return 6; // us
    if (strcmp(keyString, "y") == 0) return 6; // german
	if (strcmp(keyString, "x") == 0) return 7;
	if (strcmp(keyString, "c") == 0) return 8;
	if (strcmp(keyString, "v") == 0) return 9;
	// what is 10?
	if (strcmp(keyString, "b") == 0) return 11;
	if (strcmp(keyString, "q") == 0) return 12;
	if (strcmp(keyString, "w") == 0) return 13;
	if (strcmp(keyString, "e") == 0) return 14;
	if (strcmp(keyString, "r") == 0) return 15;
	//if (strcmp(keyString, "y") == 0) return 16; // US
    if (strcmp(keyString, "z") == 0) return 16; // german
	if (strcmp(keyString, "t") == 0) return 17;
	if (strcmp(keyString, "1") == 0) return 18;
	if (strcmp(keyString, "2") == 0) return 19;
	if (strcmp(keyString, "3") == 0) return 20;
	if (strcmp(keyString, "4") == 0) return 21;
	if (strcmp(keyString, "6") == 0) return 22;
	if (strcmp(keyString, "5") == 0) return 23;
	if (strcmp(keyString, "=") == 0) return 24;
	if (strcmp(keyString, "9") == 0) return 25;
	if (strcmp(keyString, "7") == 0) return 26;
	if (strcmp(keyString, "-") == 0) return 27;
	if (strcmp(keyString, "8") == 0) return 28;
	if (strcmp(keyString, "0") == 0) return 29;
	if (strcmp(keyString, "]") == 0) return 30;
	if (strcmp(keyString, "o") == 0) return 31;
	if (strcmp(keyString, "u") == 0) return 32;
	if (strcmp(keyString, "[") == 0) return 33;
	if (strcmp(keyString, "i") == 0) return 34;
	if (strcmp(keyString, "p") == 0) return 35;
	if (strcmp(keyString, "RETURN") == 0) return 36;
	if (strcmp(keyString, "l") == 0) return 37;
	if (strcmp(keyString, "j") == 0) return 38;
	if (strcmp(keyString, "'") == 0) return 39;
	if (strcmp(keyString, "k") == 0) return 40;
	if (strcmp(keyString, ";") == 0) return 41;
	if (strcmp(keyString, "\\") == 0) return 42;
	if (strcmp(keyString, ",") == 0) return 43;
	if (strcmp(keyString, "/") == 0) return 44;
	if (strcmp(keyString, "n") == 0) return 45;
	if (strcmp(keyString, "m") == 0) return 46;
	if (strcmp(keyString, ".") == 0) return 47;
	if (strcmp(keyString, "TAB") == 0) return 48;
	if (strcmp(keyString, "SPACE") == 0) return 49;
	if (strcmp(keyString, "`") == 0) return 50;
	if (strcmp(keyString, "DELETE") == 0) return 51;
	if (strcmp(keyString, "ENTER") == 0) return 52;
	if (strcmp(keyString, "ESCAPE") == 0) return 53;
    
	// some more missing codes abound, reserved I presume, but it would
	// have been helpful for Apple to have a document with them all listed
    
	if (strcmp(keyString, ".") == 0) return 65;
    
	if (strcmp(keyString, "*") == 0) return 67;
    
	if (strcmp(keyString, "+") == 0) return 69;
    
	if (strcmp(keyString, "CLEAR") == 0) return 71;
    
	if (strcmp(keyString, "/") == 0) return 75;
	if (strcmp(keyString, "ENTER") == 0) return 76;  // numberpad on full kbd
    
	if (strcmp(keyString, "=") == 0) return 78;
	
	if (strcmp(keyString, "=") == 0) return 81;
	if (strcmp(keyString, "0") == 0) return 82;
	if (strcmp(keyString, "1") == 0) return 83;
	if (strcmp(keyString, "2") == 0) return 84;
	if (strcmp(keyString, "3") == 0) return 85;
	if (strcmp(keyString, "4") == 0) return 86;
	if (strcmp(keyString, "5") == 0) return 87;
	if (strcmp(keyString, "6") == 0) return 88;
	if (strcmp(keyString, "7") == 0) return 89;
	
	if (strcmp(keyString, "8") == 0) return 91;
	if (strcmp(keyString, "9") == 0) return 92;
    
	if (strcmp(keyString, "F5") == 0) return 96;
	if (strcmp(keyString, "F6") == 0) return 97;
	if (strcmp(keyString, "F7") == 0) return 98;
	if (strcmp(keyString, "F3") == 0) return 99;
	if (strcmp(keyString, "F8") == 0) return 100;
	if (strcmp(keyString, "F9") == 0) return 101;
	
	if (strcmp(keyString, "F11") == 0) return 103;
	
	if (strcmp(keyString, "F13") == 0) return 105;
	
	if (strcmp(keyString, "F14") == 0) return 107;
	
	if (strcmp(keyString, "F10") == 0) return 109;
	
	if (strcmp(keyString, "F12") == 0) return 111;
    
	if (strcmp(keyString, "F15") == 0) return 113;
	if (strcmp(keyString, "HELP") == 0) return 114;
	if (strcmp(keyString, "HOME") == 0) return 115;
	if (strcmp(keyString, "PGUP") == 0) return 116;
	if (strcmp(keyString, "DELETE") == 0) return 117;
	if (strcmp(keyString, "F4") == 0) return 118;
	if (strcmp(keyString, "END") == 0) return 119;
	if (strcmp(keyString, "F2") == 0) return 120;
	if (strcmp(keyString, "PGDN") == 0) return 121;
	if (strcmp(keyString, "F1") == 0) return 122;
	if (strcmp(keyString, "LEFT") == 0) return 123;
	if (strcmp(keyString, "RIGHT") == 0) return 124;
	if (strcmp(keyString, "DOWN") == 0) return 125;
	if (strcmp(keyString, "UP") == 0) return 126;
    
	NSLog(@"keyString %s Not Found. Aborting...", keyString);
    return 0;
}

- (void)typeText:(NSString *)text
{
    char aChar[2] = "+";
    NSCharacterSet * set = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ"];
    
    int i = 0;
    for(i=0;i<text.length;i++)
    {
        NSString *substr = [text substringWithRange:NSMakeRange(i, 1)];
        BOOL pressShift = NO;
        BOOL nonAlpha = NO;
        if ([substr rangeOfCharacterFromSet:set].location == NSNotFound) {
            nonAlpha = YES;
        }
        
        if([substr isEqualToString:[substr uppercaseString]] && nonAlpha == NO)
        {
            // uppercase, add shifmk)tt
            pressShift= YES;
        }
        
        NSLog(@"str: %@", substr);
        
        *aChar = [[substr lowercaseString] characterAtIndex:0];
        
        int code = keyCodeForKeyString(aChar);
        
        CGEventRef event1;
        event1 = CGEventCreateKeyboardEvent (NULL, (CGKeyCode)code, true);
        
        if(pressShift)
        {
            CGEventSetFlags(event1, kCGEventFlagMaskShift);
        }
        else
        {
            CGEventSetFlags(event1, 0);
        }
        CGEventPost(kCGSessionEventTap, event1);
        CFRelease(event1);
        
        
        
    }
}

- (void)leftClickDown:(CGPoint)click
{
    
    CGMouseButton button = kCGMouseButtonLeft;
    CGEventType type = kCGEventLeftMouseDown;
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, click, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

- (void)leftClickUp:(CGPoint)click
{
    
    CGMouseButton button = kCGMouseButtonLeft;
    CGEventType type = kCGEventLeftMouseUp;
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, click, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}

- (void)moveMouse:(CGPoint)click
{
    
    CGEventType type = kCGEventMouseMoved;
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, click, 0);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
}



- (void)leftClickDownUp:(CGPoint)click
{
    
    CGMouseButton button = kCGMouseButtonLeft;
    CGEventType type = kCGEventLeftMouseDown;
    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, type, click, button);
    CGEventSetType(theEvent, type);
    CGEventPost(kCGHIDEventTap, theEvent);
    CFRelease(theEvent);
    
    [NSThread sleepForTimeInterval:.1f];
    
    CGMouseButton button2 = kCGMouseButtonLeft;
    CGEventType type2 = kCGEventLeftMouseUp;
    CGEventRef theEvent2 = CGEventCreateMouseEvent(NULL, type2, click, button2);
    CGEventSetType(theEvent2, type2);
    CGEventPost(kCGHIDEventTap, theEvent2);
    CFRelease(theEvent2);
}

- (void)sendEnter
{
    CGEventRef event1;
    event1 = CGEventCreateKeyboardEvent (NULL, 36, true);
    CGEventPost(kCGSessionEventTap, event1);
    CFRelease(event1);
}

- (void)takeScreenshot:(NSInteger)num
{
    CGImageRef capturedImage = CGDisplayCreateImage(kCGDirectMainDisplay);
    capturedImage = CGImageCreateWithImageInRect(capturedImage, self.screenshotSize);
    
    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:capturedImage];
    NSData *data = [bitmapRep representationUsingType:NSPNGFileType properties: nil];
    [data writeToFile:[NSString stringWithFormat:@"/Users/jonasschnelli/Desktop/screens/%ld.png", self.currentScreenshotNum] atomically:YES];
    
    self.currentScreenshotNum++;
}

@end
