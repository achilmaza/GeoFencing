//
//  ViewController.m
//  GeoParent
//
//  Created by Aditya Narayan on 7/27/15.
//  Copyright (c) 2015 AC. All rights reserved.
//

#import "ViewController.h"
#import "ConvertJSONUtility.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *mUsernameField;
@property (weak, nonatomic) IBOutlet UITextField *mLongitudeField;
@property (weak, nonatomic) IBOutlet UITextField *mLatitudeField;
@property (weak, nonatomic) IBOutlet UITextField *mRadiusField;
@property (weak, nonatomic) IBOutlet UILabel *mStatusField;
@property (strong, nonatomic) RestAPI* mRestApi;
@property (strong, nonatomic) CLLocationManager* mLocationManager;


- (IBAction)createUser:(id)sender;
- (IBAction)updateUser:(id)sender;
- (IBAction)getStatus:(id)sender;

-(NSDictionary*)setupUserDetails;
-(void)httpGetRequest:(NSString*)username;
-(void)httpPostRequest:(NSDictionary*)userDetails;
-(void)httpPatchRequest:(NSDictionary*)userDetails;
-(void)setFieldsFromDict:(NSDictionary*)dict;

- (void)startLocation;
- (void)stopLocation;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mRestApi = [[RestAPI alloc]init];
    self.mLocationManager = [[CLLocationManager alloc]init];
    
    [self startLocation];
}

//POST
- (IBAction)createUser:(id)sender {
    
    NSDictionary* userDetails = [self setupUserDetails];

    if(userDetails != nil){
        [self httpPostRequest:userDetails];
    }
    
}

//PATCH
- (IBAction)updateUser:(id)sender {
    
    NSDictionary* userDetails = [self setupUserDetails];
    
    if(userDetails != nil){
        [self httpPatchRequest:userDetails];
    }
}

//GET
- (IBAction)getStatus:(id)sender {
    
    NSString* username  = [self.mUsernameField text];
    
    NSLog(@"getStatus usr=%@\n", username);
    
    if([username length]){
        [self httpGetRequest:username];
    }
}


-(NSDictionary*)setupUserDetails{
    
    NSString* username  = [self.mUsernameField text];
    NSString* longitude = [self.mLongitudeField text];
    NSString* latitude  = [self.mLatitudeField text];
    NSString* radius    = [self.mRadiusField text];
    
    NSDictionary* userDetails = nil;
    
    if([username length] &&
       [latitude length] &&
       [longitude length] &&
       [radius length]) {
        
        userDetails = @{@"utf8": @"✓",
                        @"authenticity_token":@"EvZva3cKnzo3Y0G5R3NktucCr99o/2UWOPVAmJYdBOc=",
                        @"user":@{@"username":username, @"latitude":latitude,
                                 @"longitude":longitude,@"radius":radius},
                        @"commit":@"Create User",
                        @"action":@"update",
                        @"controller":@"users"};
    }
    
    return userDetails;
}


-(void)httpGetRequest:(NSString*)username {
  
    NSString * userString = [username stringByAppendingString:@".json"];
    NSString* str = @"http://protected-wildwood-8664.herokuapp.com/users/";
    str = [str stringByAppendingString:userString];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
           
    NSURL* url = [NSURL URLWithString:str];
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.mRestApi.mDelegate = self;
    [self.mRestApi httpRequest:request];
}

-(void)httpPostRequest:(NSDictionary*)userDetails {
    
    NSData* postBody = [ConvertJSONUtility convertDictToJSON:userDetails];
    NSString* str = @"http://protected-wildwood-8664.herokuapp.com/users";
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [NSURL URLWithString:str];
    NSMutableURLRequest*request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    self.mRestApi.mDelegate = self;
    [self.mRestApi httpRequest:request];

}

-(void)httpPatchRequest:(NSDictionary*)userDetails {
    
    NSData* postBody = [ConvertJSONUtility convertDictToJSON:userDetails];
    NSString* username = [[userDetails objectForKey:@"user"] objectForKey:@"username"];
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
    
    NSLog(@"getReceivedData 1= %@\n", data);
//    NSLog(@"getReceivedData = %lu\n", (unsigned long)[data length]);
    
    if([data length]){
        NSDictionary* dict = [ConvertJSONUtility convertJSONToDict:data];
        
//        NSString * myData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", myData);
        NSLog(@"getReceivedData 2= %@\n", dict);
        
        if(dict!=nil && [dict count]){
            [self setFieldsFromDict:dict];
        }
    }
    
}

-(void)setFieldsFromDict:(NSDictionary*)dict {

    //Error? User not found?
    NSString*error = [dict valueForKey:@"error"];
    if(![error isEqual:[NSNull null]] && error!=nil){
        
        if([error caseInsensitiveCompare:@"not found"] == NSOrderedSame){
            [self setAlert:@"" withMessage:@"User not found"];
        }
        else{
           [self setAlert:@"" withMessage:error];
        }
        
        return;
    }
    

    NSNumber * status   = [dict valueForKey:@"is_in_zone"];
    NSString * statusStr = @"Unknown";
    

   if(![status isEqual:[NSNull null]] && status!=nil){
     
        NSLog(@"self.mStatusField = %@ \n", self.mStatusField);
       
        if([status intValue] == 1){
            statusStr = @"Yes";
//            [self.mStatusField setText:@"Yes"];
        }
        else if([status intValue] == 0){
             statusStr = @"No";
//            [self.mStatusField setText:@"No"];
        }
    }

    //Issue Alert with "In Zone" value
    [self setAlert:@"In Zone?" withMessage:statusStr];

    
    NSNumber * latitude = [dict valueForKey:@"latitude"];
    if(![latitude isEqual:[NSNull null]] && latitude!=nil){
          NSLog(@"self.mStatusField = %@ \n", self.mLatitudeField);
         [self.mLatitudeField setText: [NSString stringWithFormat:@"%.5f", [latitude floatValue]]];
    }
    
    NSNumber* longitude = [dict valueForKey:@"longitude"];
    if(![longitude isEqual:[NSNull null]] && longitude!=nil){
        [self.mLongitudeField setText:[NSString stringWithFormat:@"%.5f", [longitude floatValue]]];
    }
    
    NSNumber* radius = [dict valueForKey:@"radius"];
    if(![radius isEqual:[NSNull null]] && radius!=nil){
        [self.mRadiusField setText:[NSString stringWithFormat:@"%.5f", [radius floatValue]]];
    }
    

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

//Geo Location
- (void)startLocation {
    
    NSLog(@"START \n");
    
    self.mLocationManager.delegate = self;  //set view controller as delegate of geolocation manager
    self.mLocationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([self.mLocationManager respondsToSelector:@selector(requestWhenInUseAuthorization)] == YES){
        [self.mLocationManager requestWhenInUseAuthorization];
    }
    
    [self.mLocationManager startUpdatingLocation];
    
}

- (void)stopLocation {
    
    NSLog(@"STOP \n");
    [self.mLocationManager stopUpdatingLocation];
    
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
        
        [self stopLocation];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES]; //get rid of keyboard
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
