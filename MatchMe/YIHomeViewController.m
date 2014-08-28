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
@property (strong, nonatomic) PFObject *photo;  // current photo on screen
@property (strong, nonatomic) NSMutableArray *activities; // keep track of activities

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
    [query includeKey:kYIPhotoUserKey];  // include the actual User object when we retrieve a photo
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
    [self checkLike];
}

- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
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
        PFFile *file = self.photo[kYIPhotoPictureKey];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                UIImage *image = [UIImage imageWithData:data];
                self.photoImageView.image = image;
                [self updateView];
            } else NSLog(@"Failed to download photo:%@", error);
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:kYIActivityClassKey];
        [queryForLike whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeLikeKey];
        [queryForLike whereKey:kYIActivityPhotoKey equalTo:self.photo];
        [queryForLike whereKey:kYIActivityFromUserKey equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:kYIActivityClassKey];
        [queryForDislike whereKey:kYIActivityTypeKey equalTo:kYIActivityTypeDislikeKey];
        [queryForDislike whereKey:kYIActivityPhotoKey equalTo:self.photo];
        [queryForDislike whereKey:kYIActivityFromUserKey equalTo:[PFUser currentUser]];
        
        // Join the 2 queries
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.activities = [objects mutableCopy];
                if ([self.activities count] == 0) {
                    self.isLikedByCurrentUser = NO;
                    self.isDislikedByCurrentUser = NO;
                } else {
                    // does in fact have either a like or dislike
                    PFObject *activity = self.activities[0];
                    if ([activity[kYIActivityTypeKey] isEqualToString:kYIActivityTypeLikeKey]) {
                        self.isLikedByCurrentUser = YES;
                        self.isDislikedByCurrentUser = NO;
                    } else if ([activity[kYIActivityTypeKey] isEqualToString:kYIActivityTypeDislikeKey]) {
                        self.isLikedByCurrentUser = NO;
                        self.isDislikedByCurrentUser = YES;
                    } else {
                        // some sort of other activity
                    }
                    
                }
                self.likeButton.enabled = YES;
                self.dislikeButton.enabled = YES;
            } else {
                NSLog(@"%@", error);
            }
        }];
    }
}

- (void) updateView {
    self.firstNameLabel.text = self.photo[kYIPhotoUserKey][kYIUserProfileKey][kYIUserProfileFirstNameKey];
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[kYIPhotoUserKey][kYIUserProfileKey][kYIUserProfileAgeKey]];  // we use string with format here because age is an int
    self.tagLineLabel.text = self.photo[kYIPhotoUserKey][kYIUserTagLineKey];
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
    PFObject *likeActivity = [PFObject objectWithClassName:kYIActivityClassKey];
    [likeActivity setObject:kYIActivityTypeLikeKey forKey:kYIActivityTypeKey];
    [likeActivity setObject:[PFUser currentUser] forKey:kYIActivityFromUserKey];
    [likeActivity setObject:self.photo[kYIPhotoUserKey] forKey:kYIActivityToUserKey];
    [likeActivity setObject:self.photo forKey:kYIActivityPhotoKey];
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = YES;
        self.isDislikedByCurrentUser = NO;
        [self.activities addObject:likeActivity];
        [self setupNextPhoto];
    }];
}

- (void)saveDislike {
    PFObject *dislikeActivity = [PFObject objectWithClassName:kYIActivityClassKey];
    [dislikeActivity setObject:kYIActivityTypeDislikeKey forKey:kYIActivityTypeKey];
    [dislikeActivity setObject:[PFUser currentUser] forKey:kYIActivityFromUserKey];
    [dislikeActivity setObject:self.photo[kYIPhotoUserKey] forKey:kYIActivityToUserKey];
    [dislikeActivity setObject:self.photo forKey:kYIActivityPhotoKey];
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.isLikedByCurrentUser = NO;
        self.isDislikedByCurrentUser = YES;
        [self.activities addObject:dislikeActivity];
        [self setupNextPhoto];
    }];
}

// Check if we've already liked someone
- (void) checkLike {
    if (self.isLikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    } else if (self.isDislikedByCurrentUser) {
        for (PFObject *activity in self.activities){
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveLike];
    } else {
        [self saveLike];
    }
}

// Check if we already disliked the user, if we have, move to next uers
// If we liked the user, delete the like from activities, and Parse, save dislike
// Otherwise, we just save the dislike
- (void) checkDislike {
    if (self.isDislikedByCurrentUser) {
        [self setupNextPhoto];
        return;
    } else if (self.isLikedByCurrentUser) {
        for (PFObject *activity in self.activities) {
            [activity deleteInBackground];
        }
        [self.activities removeLastObject];
        [self saveDislike];
    } else {
        [self saveDislike];
    }
}



@end
