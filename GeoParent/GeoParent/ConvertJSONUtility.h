//
//  ConvertUtility.h
//  GeoParent
//
//  Created by Aditya Narayan on 7/27/15.
//  Copyright (c) 2015 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertJSONUtility : NSObject

+(NSData*) convertDictToJSON:(NSDictionary*)dict;
+(NSDictionary*) convertJSONToDict:(NSData*)data;


@end
