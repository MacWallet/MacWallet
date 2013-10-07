//
//  BATickerController.h
//  MacWallet
//
//  Created by Jonas Schnelli on 04.10.13.
//  Copyright (c) 2013 Jonas Schnelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWTickerController : NSObject
@property (strong) NSString *tickerFilePath;
+ (MWTickerController *)defaultController;
- (void)loadTicketWithName:(NSString *)name completionHandler:(void (^)(NSString*, NSError*))handler;
@property (readonly) NSDictionary *tickerDatabase;
@end
