//
//  YIHomeViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/26/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIHomeViewController.h"
#import <Parse/Parse.h>
#import "YIConstants.h"

@interface YIHomeViewController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButtonItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButtonItem;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;  // store all photos we get back from Parse
@property (nonatomic) int currentPhotoIndex;    // keep track of current photo in the photos array


@end

@implementation YIHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.likeButton.enabled = NO;
    self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:kYIPhotoClassKey];
    [query includeKey:@"user"];  // include the actual User object when we retrieve a photo
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photos = objects;
        } else {
            NSLog(@"Error:%@", error);
        }
    }];
    
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
- (IBAction)likeButtonPressed:(UIButton *)sender {
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    
}

- (IBAction)infoButtonPressed:(UIButton *)sender {
    
}

- (IBAction)settingsBarButtonItemPressed:(UIBarButtonItem *)sender {
}

- (IBAction)chatBarButtonItemPressed:(UIBarButtonItem *)sender {
}

@end
