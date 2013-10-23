//
//  I7MacInterfaceAutomation.h
//  MacWallet
//
//  Created by Jonas Schnelli on 18.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface I7MacInterfaceAutomation : NSObject
int keyCodeForKeyString(char * keyString);

- (void)leftClickDownUp:(CGPoint)click;
- (void)leftClickUp:(CGPoint)click;
- (void)moveMouse:(CGPoint)click;
- (void)leftClickDown:(CGPoint)click;
- (void)sendEnter;
- (void)sendTab;
- (void)sendBackspace;
- (void)typeText:(NSString *)text;
- (void)takeScreenshot:(NSInteger)num;
@property (assign) CGRect screenshotSize;
@property (assign) NSInteger currentScreenshotNum;
@property (strong) NSString *language;
@end
