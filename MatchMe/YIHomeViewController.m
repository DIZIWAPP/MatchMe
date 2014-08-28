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
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities; // keep track of actions

@property (nonatomic) int currentPhotoIndex;    // keep track of current photo in the photos array
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;



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
            [self queryForCurrentPhotoIndex];
            
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

#pragma mark - Helper Methods
- (void)queryForCurrentPhotoIndex {
    if ([self.photos count] > 0) {
        self.photo = self.photos[self.currentPhotoIndex];
        PFFile *file = self.photo[@"image"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            } else NSLog(@"Failed to download photo:%@", error);
        }];
    }
}

- (void) updateView {
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"first_name"];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[@"user"][@"profile"][@"age"]];  // we use string with format here because age is an int
    self.tagLineLabel.text = self.photo[@"user"][@"tagLine"];
}

- (void)setupNextPhoto {
    if (self.currentPhotoIndex + 1 < [self.photos count]) {
        self.currentPhotoIndex++;
        [self queryForCurrentPhotoIndex];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check back later for more people!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)saveLike {
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    [likeActivity setObject:@"like" forKey:@"type"];
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [likeActivity setObject:self.photo[@"user"] forKey:@"toUser"];
    [likeActivity setObject:self.photo forKey:@"photo"];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
    [dislikeActivity setObject:@"dislike" forKey:@"type"];
    [dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [dislikeActivity setObject:self.photo[@"user"] forKey:@"toUser"];
    [dislikeActivity setObject:self.photo forKey:@"photo"];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

@end
