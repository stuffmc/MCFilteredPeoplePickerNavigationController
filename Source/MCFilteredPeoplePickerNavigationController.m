//
//  MCFilteredPeoplePickerNavigationController.h
//  MCFilteredPeoplePickerNavigationController
//
//  Created by Manuel "StuFF mc" Carrasco Molina on 30/12/12.
//  Copyright (c) 2012 Pomcast.biz. All rights reserved.
//

#import "MCFilteredPeoplePickerNavigationController.h"
#import "MCFilteredPeoplePickerTableViewController.h"

@interface MCFilteredPeoplePickerNavigationController ()

@property (nonatomic, strong) MCFilteredPeoplePickerTableViewController *filteredPeoplePickerTableViewController;

@end

@implementation MCFilteredPeoplePickerNavigationController

- (id)init
{
    _filteredPeoplePickerTableViewController = [[MCFilteredPeoplePickerTableViewController alloc] init];
    _filteredPeoplePickerTableViewController.peoplePickerDelegate = self.peoplePickerDelegate;
    _filteredPeoplePickerTableViewController.filteredPeoplePickerNavigationController = self;
    if (self = [super initWithRootViewController:_filteredPeoplePickerTableViewController]) {
    }
    return self;
}

- (void)setPeoplePickerDelegate:(id<MCFilteredPickerNavigationControllerDelegate>)peoplePickerDelegate
{
    _filteredPeoplePickerTableViewController.peoplePickerDelegate = peoplePickerDelegate;
    _peoplePickerDelegate = peoplePickerDelegate;
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{    }];
}

@end
