//
//  MCFilteredPeoplePickerTableViewController.h
//  MCFilteredPeoplePickerNavigationController
//
//  Created by Manuel "StuFF mc" Carrasco Molina on 29/12/12.
//  Copyright (c) 2012 Pomcast.biz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol MCFilteredPickerNavigationControllerDelegate;
#import "MCFilteredPeoplePickerNavigationController.h"

@interface MCFilteredPeoplePickerTableViewController : UITableViewController <ABPersonViewControllerDelegate>

@property(nonatomic,assign)    id<MCFilteredPickerNavigationControllerDelegate>    peoplePickerDelegate;
@property(nonatomic, strong) MCFilteredPeoplePickerNavigationController *filteredPeoplePickerNavigationController;

@end
