//
//  RestAPI.h
//  GoogleFetch
//
//  Created by Angie Chilmaza on 7/26/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestAPIDelegate.h"

@interface RestAPI : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, weak) id <RestAPIDelegate> mDelegate;

-(void)httpRequest: (NSMutableURLRequest*)request;

@end
