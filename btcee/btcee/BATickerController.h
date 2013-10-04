//
//  BATickerController.h
//  btcee
//
//  Created by Jonas Schnelli on 04.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BATickerController : NSObject
@property (strong) NSString *tickerFilePath;
+ (BATickerController *)defaultController;
- (void)loadTicketWithName:(NSString *)name completionHandler:(void (^)(NSString*, NSError*))handler;
@end
