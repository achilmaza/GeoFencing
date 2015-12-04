//
//  ConvertUtility.m
//  GeoParent
//
//  Created by Aditya Narayan on 7/27/15.
//  Copyright (c) 2015 AC. All rights reserved.
//

#import "ConvertJSONUtility.h"

@implementation ConvertJSONUtility


+(NSData*) convertDictToJSON:(NSDictionary*)dict {
    
    NSError* error = nil;
    NSData* data = [NSJSONSerialization dataWithJSONObject:dict
                                                   options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"convertDictToJSON %@", error.localizedDescription);
    }
    
    
    return data;
}


//Convert JSON to Dictionary
+(NSDictionary*) convertJSONToDict:(NSData*)data{
    
    NSError* error = nil;
    NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (error) {
        NSLog(@"convertJSONToDict %@", error.localizedDescription);
    }
    
    return result;
}



@end
