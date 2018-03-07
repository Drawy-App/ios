//
//  GA.h
//  htd
//
//  Created by Alexey Landyrev on 07.03.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Google/Analytics.h>
#import <StoreKit/StoreKit.h>

@interface GA : NSObject
+ (void)initGA;
+ (void)pageOpened:(NSString*)pageName;
+ (void)paidAction:(SKProduct*)product :(NSString*)transactionId;
@end
