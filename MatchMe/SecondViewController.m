//
//  SecondViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/25/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "SecondViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"

@interface SecondViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;

@end

@implementation SecondViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:kYIPhotoClassKey];
    [query whereKey:kYIPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kYIPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.profilePictureImageView.image = [UIImage imageWithData:data];
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
