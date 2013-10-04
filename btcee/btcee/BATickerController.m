//
//  BATickerController.m
//  btcee
//
//  Created by Jonas Schnelli on 04.10.13.
//  Copyright (c) 2013 include7 AG. All rights reserved.
//

#import "BATickerController.h"

static BATickerController *sharedInstance;

@interface BATickerController ()
@property (strong) NSDictionary *tickerDictionary;
@end

@implementation BATickerController

@synthesize tickerFilePath=_tickerFilePath;

+ (BATickerController *)defaultController
{
    if(!sharedInstance)
    {
        sharedInstance = [[BATickerController alloc] init];
    }
    
    return sharedInstance;
}

- (void)setTickerFilePath:(NSString *)tickerFilePath
{
    _tickerFilePath = tickerFilePath;
    self.tickerDictionary = [NSDictionary dictionaryWithContentsOfFile:self.tickerFilePath];
}

- (NSString *)tickerFilePath
{
    return _tickerFilePath;
}

- (void)loadTicketWithName:(NSString *)name completionHandler:(void (^)(NSString*, NSError*))handler
{
    NSDictionary *tickerObject = [self.tickerDictionary objectForKey:name];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[tickerObject objectForKey:@"url"]]];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error == nil && data)
        {
            NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            NSString *pathToValue = [tickerObject objectForKey:@"jsonPath"];
            NSArray *comps = [pathToValue componentsSeparatedByString:@"."];
            NSDictionary *currentDict = jsonObject;
            for(NSString *comp in comps)
            {
                currentDict = [currentDict objectForKey:comp];
            }
            handler([NSString stringWithFormat:[tickerObject objectForKey:@"format"],(NSString *)currentDict], nil);
        }
        else {
            handler(nil, error);
        }
    }];
}

@end
