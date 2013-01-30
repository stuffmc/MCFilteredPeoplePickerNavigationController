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

- (id)initWithDelegate:(id<MCFilteredPickerNavigationControllerDelegate>)peoplePickerDelegate
{
    self.filteredPeoplePickerTableViewController = [[MCFilteredPeoplePickerTableViewController alloc] init];
    if (self.filteredPeoplePickerTableViewController) {
        if ((self = [super initWithRootViewController:self.filteredPeoplePickerTableViewController])) {
            self.filteredPeoplePickerTableViewController.peoplePickerDelegate = peoplePickerDelegate;
            self.filteredPeoplePickerTableViewController.filteredPeoplePickerNavigationController = self;
        }
        return self;
    } else {
        return nil;
    }
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
