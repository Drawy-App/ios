//
//  GA.m
//  htd
//
//  Created by Alexey Landyrev on 07.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

#import "GA.h"

@implementation GA

+ (id<GAITracker>)getTracker {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    tracker.allowIDFACollection = YES;
    return tracker;
}

+ (void)initGA {
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
}

+ (void)pageOpened:(NSString*)pageName {
    id<GAITracker> tracker = [self getTracker];
    [tracker set:kGAIScreenName value:pageName];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void)paidAction:(SKProduct*)product :(NSString*)transactionId {
    id<GAITracker> tracker = [self getTracker];
    [tracker send:[[GAIDictionaryBuilder
                    createItemWithTransactionId:transactionId
                    name:product.productIdentifier
                    sku:product.productIdentifier category:@"general" price:product.price
                    quantity: [NSNumber numberWithInt:1]
                    currencyCode:product.priceLocale.currencyCode] build]];
}

@end
