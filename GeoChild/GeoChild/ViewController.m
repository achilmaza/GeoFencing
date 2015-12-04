//
//  ViewController.m
//  GeoChild
//
//  Created by Aditya Narayan on 7/27/15.
//  Copyright (c) 2015 AC. All rights reserved.
//

#import "ViewController.h"
#import "ConvertJSONUtility.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *mParentUsernameField;
@property (weak, nonatomic) IBOutlet UILabel *mLatitudeField;
@property (weak, nonatomic) IBOutlet UILabel *mLongitudeField;
@property (strong, nonatomic) RestAPI* mRestApi;
@property (strong, nonatomic) CLLocationManager* mLocationManager;


- (IBAction)startLocation:(id)sender;
- (IBAction)stopLocation:(id)sender;
-(NSDictionary*)setupChildDetails;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mRestApi = [[RestAPI alloc]init];
    self.mLocationManager = [[CLLocationManager alloc]init];
}

- (IBAction)startLocation:(id)sender {
    
    NSLog(@"START \n");
    
    if([self.mParentUsernameField.text length]){
        
        self.mLocationManager.delegate = self;  //set view controller as delegate of geolocation manager
        self.mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        if([self.mLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)] == YES){
            [self.mLocationManager requestAlwaysAuthorization];
        }
        
        [self.mLocationManager startUpdatingLocation];
    }
    else{
        [self setAlert:@"" withMessage:@"Enter valid username"];
    }
}

- (IBAction)stopLocation:(id)sender {
    
    NSLog(@"STOP \n");
    [self.mLocationManager stopUpdatingLocation];
    
}

-(void)setAlert:(NSString*)title withMessage:(NSString*)msg{
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

//Location manager delegate methods
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    
    NSLog(@"Error: %@\n", error);
    NSLog(@"Failed to get location \n");
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager:didUpdateLocations \n");
    
    CLLocation* currentLocation = [locations lastObject];
    
    if(currentLocation != nil){
        
        NSLog(@"Current location = %@n", currentLocation);
        [self.mLatitudeField setText: [NSString stringWithFormat:@"%.5f", currentLocation.coordinate.latitude]];
        [self.mLongitudeField setText: [NSString stringWithFormat:@"%.5f", currentLocation.coordinate.longitude]];
        
        //send patch request
        NSDictionary* childDetails = [self setupChildDetails];
        if(childDetails != nil){
            [self httpPatchRequest:childDetails];
        }
        
    }
}

-(NSDictionary*)setupChildDetails{
    
    NSString* username  = [self.mParentUsernameField text];
    NSString* longitude = [self.mLongitudeField text];
    NSString* latitude  = [self.mLatitudeField text];
    
    NSDictionary* childDetails = nil;
    
    if([username length] &&
       [latitude length] &&
       [longitude length]){
        
        childDetails = @{@"utf8": @"✓",
                         @"authenticity_token":@"EvZva3cKnzo3Y0G5R3NktucCr99o/2UWOPVAmJYdBOc=",
                         @"user":@{@"username":username,
                                   @"current_lat":latitude,
                                   @"current_longitude":longitude},
                         @"commit":@"Create User",
                         @"action":@"update",
                         @"controller":@"users"};
    }
    
    return childDetails;
}


-(void)httpPatchRequest:(NSDictionary*)childDetails {
    
    NSData* postBody = [ConvertJSONUtility convertDictToJSON:childDetails];
    NSString* username = [[childDetails objectForKey:@"user"] objectForKey:@"username"];
    NSString* str = @"http://protected-wildwood-8664.herokuapp.com/users/";
    str = [str stringByAppendingString:username];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [NSURL URLWithString:str];
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"PATCH"];
    [request setHTTPBody:postBody];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.mRestApi.mDelegate = self;
    [self.mRestApi httpRequest:request];
    
}


-(void)getReceivedData:(NSMutableData *)data sender:(RestAPI *)sender{
    
    NSLog(@"getReceivedData = %@\n", data);
    NSLog(@"getReceivedData = %lu\n", (unsigned long)[data length]);
    
    if([data length]){
        NSDictionary* dict = [ConvertJSONUtility convertJSONToDict:data];
        NSLog(@"getReceivedData = %@\n", dict);
        
        NSString*error = [dict valueForKey:@"error"];
        if(![error isEqual:[NSNull null]] && error!=nil){
            
            if([error caseInsensitiveCompare:@"not found"] == NSOrderedSame){
                [self setAlert:@"" withMessage:@"User not found. Location stopped"];
            }
            else{
                [self setAlert:@"" withMessage:error];
            }
            
            [self.mLocationManager stopUpdatingLocation];
            
        }
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
