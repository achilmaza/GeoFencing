//
//  RestAPI.m
//  GoogleFetch
//
//  Created by Angie Chilmaza on 7/26/15.
//  Copyright (c) 2015 Angie Chilmaza. All rights reserved.
//

#import "RestAPI.h"

@interface RestAPI()

@property (nonatomic, strong) NSMutableData* mReceivedData;
@property (nonatomic, strong) NSURLConnection* mRequestedConnection;

@end


@implementation RestAPI

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.mReceivedData = [[NSMutableData alloc]init];
        self.mRequestedConnection   = [[NSURLConnection alloc]init];
        
    }
    return self;
}

-(void) httpRequest:(NSMutableURLRequest*) request{

   self.mRequestedConnection = [NSURLConnection connectionWithRequest:request delegate:self];
      
}

//delegate methods
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    if(data != nil){
        
        if(self.mReceivedData == nil){
            self.mReceivedData = [[NSMutableData alloc]initWithData:data];
        }
        else{
            [self.mReceivedData appendData:data];
        }
    }
    
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    NSLog(@"connection:didReceiveResponse: %@\n", response);
    
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@"connectionDidFinishLoading %@ \n", connection);
    
    [self.mDelegate getReceivedData:self.mReceivedData sender:self];
    self.mDelegate = nil;
    self.mRequestedConnection = nil;
    self.mReceivedData = nil;
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if(self.mDelegate){
        [self.mDelegate setAlert:@"" withMessage:error.description];
    }
    
    NSLog(@"connection:didFailWithError %@\n", error.description);
    
}



@end
