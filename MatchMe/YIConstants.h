//
//  YIConstants.h
//  MatchMe
//
//  Created by Yi Wang on 8/25/14.
//  Copyright (c) 2014 Yi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YIConstants : NSObject

#pragma mark - User Class

extern NSString *const kYIUserTagLineKey;

extern NSString *const kYIUserProfileKey;
extern NSString *const kYIUserProfileNameKey;
extern NSString *const kYIUserProfileFirstNameKey;
extern NSString *const kYIUserProfileLocationKey;
extern NSString *const kYIUserProfileGenderKey;
extern NSString *const kYIUserProfileBirthdayKey;
extern NSString *const kYIUserProfileInterestedInKey;
extern NSString *const kYIUserProfilePictureURL;
extern NSString *const kYIUserProfileRelationshipStatusKey;
extern NSString *const kYIUserProfileAgeKey;


#pragma mark - Photo Class
extern NSString *const kYIPhotoClassKey;
extern NSString *const kYIPhotoUserKey;
extern NSString *const kYIPhotoPictureKey;

#pragma mark - Activity Class
extern NSString *const kYIActivityClassKey;
extern NSString *const kYIActivityTypeKey;
extern NSString *const kYIActivityFromUserKey;
extern NSString *const kYIActivityToUserKey;
extern NSString *const kYIActivityPhotoKey;
extern NSString *const kYIActivityTypeLikeKey;
extern NSString *const kYIActivityTypeDislikeKey;

@end
