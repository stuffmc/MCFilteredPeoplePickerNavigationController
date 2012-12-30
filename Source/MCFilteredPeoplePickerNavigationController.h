//
//  MCFilteredPeoplePickerNavigationController.h
//  MCFilteredPeoplePickerNavigationController
//
//  Created by Manuel "StuFF mc" Carrasco Molina on 30/12/12.
//  Copyright (c) 2012 Pomcast.biz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
@protocol MCFilteredPickerNavigationControllerDelegate;

@interface MCFilteredPeoplePickerNavigationController : UINavigationController

@property(nonatomic,assign)    id<MCFilteredPickerNavigationControllerDelegate>    peoplePickerDelegate;

@end


@protocol MCFilteredPickerNavigationControllerDelegate <NSObject>

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
//- (void)peoplePickerNavigationControllerDidCancel:(MCFilteredPeoplePickerNavigationController *)peoplePicker;

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person;

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier;

@end
