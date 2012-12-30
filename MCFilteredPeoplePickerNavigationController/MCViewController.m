//
//  MCViewController.m
//  MCFilteredPeoplePickerNavigationController
//
//  Created by Manuel "StuFF mc" Carrasco Molina on 29/12/12.
//  Copyright (c) 2012 Pomcast.biz. All rights reserved.
//

#import "MCViewController.h"

@interface MCViewController ()

@end

@implementation MCViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)open:(id)sender {
//    MCFilteredPeoplePickerTableViewController *tvc = [[MCFilteredPeoplePickerTableViewController alloc] init];
    MCFilteredPeoplePickerNavigationController *nc = [[MCFilteredPeoplePickerNavigationController alloc] init];
    [nc setPeoplePickerDelegate:self];
    [self presentViewController:nc animated:YES completion:^{    }];
}

#pragma mark MCFilteredPickerNavigationControllerDelegate

- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    NSLog(@"selected: %@", person);
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    NSLog(@"selected address: %@", person);
    [peoplePicker dismissViewControllerAnimated:YES completion:^{
        
    }];
    return NO;
}

@end
