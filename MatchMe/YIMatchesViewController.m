//
//  YIMatchesViewController.m
//  MatchMe
//
//  Created by Yi Wang on 8/29/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import "YIMatchesViewController.h"
#import "YIConstants.h"
#import "YIChatViewController.h"
#import <Parse/Parse.h>

@interface YIMatchesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *availableChatrooms;
@end

@implementation YIMatchesViewController

#pragma mark - Lazy Instantiation

- (NSMutableArray *)availableChatrooms {
    if (!_availableChatrooms) {
        _availableChatrooms = [[NSMutableArray alloc] init];
    }
    return _availableChatrooms;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self updateAvailableChatRooms];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    YIChatViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = sender;
    chatVC.chatRoom = self.availableChatrooms[indexPath.row];
}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.availableChatrooms count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFObject *chatRoom = [self.availableChatrooms objectAtIndex:indexPath.row];
    
    PFUser *likedUser;
    PFUser *currentUser = [PFUser currentUser];
    PFUser *testUser1 = chatRoom[@"user1"];
    if ([testUser1.objectId isEqual:currentUser.objectId]) {  // must compare Parse objects using objectId
        likedUser = [chatRoom objectForKey:@"user2"];
    } else {
        likedUser = [chatRoom objectForKey:@"user1"];
    }
    
    cell.textLabel.text = likedUser[@"profile"][@"firstName"];
    
    // cell.imageView.image = place holder image
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;  // makes sure the photo looks ok
    PFQuery *queryForPhoto = [PFQuery queryWithClassName:@"Photo"];
    [queryForPhoto whereKey:@"user" equalTo:likedUser];
    [queryForPhoto findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] > 0) {
            PFObject *photo = objects[0];
            PFFile *pictureFile = photo[kYIPhotoPictureKey];
            [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                cell.imageView.image = [UIImage imageWithData:data];
                cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }];
        }
    }];
    
    return cell;
}

#pragma mark - UITableView Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"matchesToChatSegue" sender:indexPath];

}



#pragma mark - Helper Methods

- (void) updateAvailableChatRooms {
    PFQuery *query = [PFQuery queryWithClassName:@"ChatRoom"];
    [query whereKey:@"user1" equalTo:[PFUser currentUser]];
    
    PFQuery *queryInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *queryCombined = [PFQuery orQueryWithSubqueries:@[query, queryInverse]];
    [queryCombined includeKey:@"chat"];  //get back the complete Chat class, not just the pointer
    [queryCombined includeKey:@"user1"];
    [queryCombined includeKey:@"user2"];
    
    [queryCombined findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self.availableChatrooms removeAllObjects];
            self.availableChatrooms = [objects mutableCopy];
            [self.tableView reloadData];
            
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}








@end
