//
//  YILoginViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/25/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YILoginViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"

@interface YILoginViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@end

@implementation YILoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark - IBActions

- (IBAction)loginButtonPressed:(id)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionsArray = @[@"user_about_me", @"user_interests", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];
    
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if (!user) {
            if (!error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"The Facebook Login was Canceled" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSeguey" sender:self];
        }
    }];
    
}

#pragma mark - Helper Method
- (void) updateUserInformation {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        // NSLog(@"result:%@", result);
        
        if (!error) {
            NSDictionary *userDictionary = (NSDictionary *)result;
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            if (userDictionary[@"name"]) {
                userProfile[kYIUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kYIUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kYIUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kYIUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kYIUserProfileBirthdayKey] = userDictionary[@"birthday"];
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kYIUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            [[PFUser currentUser] setObject:userProfile forKey:kYIUserProfileKey];
            [[PFUser currentUser] saveInBackground];
        } else {
            NSLog(@"Error in FB request:%@", error);
        }
    }];
    
}


@end
