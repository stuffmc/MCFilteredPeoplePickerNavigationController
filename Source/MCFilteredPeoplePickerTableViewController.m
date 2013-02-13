//
//  MCFilteredPeoplePickerTableViewController.m
//  MCFilteredPeoplePickerNavigationController
//
//  Created by Manuel "StuFF mc" Carrasco Molina on 29/12/12.
//  Copyright (c) 2012 Pomcast.biz. All rights reserved.
//

#import "MCFilteredPeoplePickerTableViewController.h"
#import <AddressBook/AddressBook.h>

@interface MCFilteredPeoplePickerTableViewController ()

@property (strong, nonatomic) NSArray *people, *searchedPeople;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController * mySearchDisplayController;

@end

#define CELL @"Cell"

@implementation MCFilteredPeoplePickerTableViewController {
    ABAddressBookRef ab;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        CFErrorRef *error = nil;
        ab = nil;
        
        // Thanks to http://mobileappsolutions.blogspot.de/2012/11/addressbook-ios-6-issues.html
        // other option (not working): CFBundleGetFunctionPointerForName(CFBundleGetBundleWithIdentifier(CFSTR("com.apple.addressbook")), CFSTR("ABAddressBookRequestAccessWithCompletion"))
        if (ABAddressBookCreateWithOptions != NULL) {   // we're on iOS 6
            ab = ABAddressBookCreateWithOptions(NULL, error);
            if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
                ABAddressBookRequestAccessWithCompletion(ab, ^(bool granted, CFErrorRef error) {
                    // First time access has been granted, add the contact
                    NSLog(@"granted: %i", granted);
                    if (!granted) {
                        // TODO: Dismiss
                    }
                    //                [self _addContactToAddressBook];
                });
            } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                // The user has previously given access, add the contact
                //            [self _addContactToAddressBook];
            } else {
                // The user has previously denied access
                // Send an alert telling user to change privacy setting in settings app
                if (ab) {
                    CFRelease(ab);
                }
                [UIAlertView showWithTitle:NSLocalizedString(@"user_rejected_access_to_addressbook", @"Message shown when the user has previously rejected access. He'll have to go in the settings.")];
                return nil;
            }
        } else {    // we're on iOS 5
            ab = ABAddressBookCreate();
        }
        if (error) {
            NSLog(@"ABAddressBookCreateWithOptions returned error code %ld", CFErrorGetCode(*error));
        }
    }
    return self;
}

- (ABMultiValueRef)multiValue:(id)record
{
    return ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonAddressProperty);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"loading_contacts", @"The title 'Loading Contacts...' on top of the Table View while loading the contacts");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(dismiss)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    self.searchBar.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _people = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(ab);
    
    // Inspired from http://developer.apple.com/library/ios/#documentation/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Chapters/DirectInteraction.html#//apple_ref/doc/uid/TP40007744-CH6-SW1
    
    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
        ABMultiValueRef multiValue = [self multiValue:record];
        BOOL result = ABMultiValueGetCount(multiValue) > 0 ? YES : NO;
        CFRelease(multiValue);
        return result;
    }];
    _people = [_people filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
    if (ab) {
        CFRelease(ab);
    }

    self.title = NSLocalizedString(@"contacts", @"The title 'Contacts' on top of the Table View once the contacts have been loaded");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self arrayForTableView:tableView] count];
}

- (NSArray*)arrayForTableView:(UITableView*)tableView
{
    return (tableView == self.tableView) ? _people : _searchedPeople;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
    }
    ABRecordRef record = (__bridge ABRecordRef)([self arrayForTableView:tableView][indexPath.row]);
    CFStringRef compositeName = ABRecordCopyCompositeName(record);
    cell.textLabel.text = (__bridge NSString *)(compositeName);
    CFRelease(compositeName);
    return cell;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.delegate = self;
    return self.searchBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.searchBar.frame.size.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id record = _people[indexPath.row];
    ABMultiValueRef multiValue = [self multiValue:record];
    ABRecordRef recordRef = (__bridge ABRecordRef)record;
    switch (ABMultiValueGetCount(multiValue)) {
        case 0:
            // That shouldn't happen, actually!
            NSLog(@"Something weird happened. This record you just clicked shouldn't happend — please report!");
            break;

        case 1:
        {
            [self.peoplePickerDelegate peoplePickerNavigationController:self.filteredPeoplePickerNavigationController shouldContinueAfterSelectingPerson:recordRef];
        }
            break;

        default:
        {
            ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
            [personViewController setPersonViewDelegate:self];
            [personViewController setDisplayedPerson:recordRef];
            [self.navigationController pushViewController:personViewController animated:YES];
        }
            break;
    }
    CFRelease(multiValue);
}

#pragma mark - ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return [[self peoplePickerDelegate] peoplePickerNavigationController:self.filteredPeoplePickerNavigationController shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
        CFStringRef compositeNameRef = ABRecordCopyCompositeName((__bridge ABRecordRef)record);
        BOOL result = [(__bridge NSString *)compositeNameRef rangeOfString:[searchString uppercaseString]].location != NSNotFound;
        CFRelease(compositeNameRef);
        return result;
    }];
    _searchedPeople = [_people filteredArrayUsingPredicate:predicate];
    return YES;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}


@end
