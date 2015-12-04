//
//  RestAPIDelegate.h
//  GoogleFetch
//
//  Created by Angie Chilmaza on 7/26/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RestAPI;

@protocol RestAPIDelegate <NSObject>

-(void) getReceivedData:(NSMutableData*) data sender:(RestAPI*)sender;
-(void) setAlert:(NSString*)title withMessage:(NSString*)msg;

@end
