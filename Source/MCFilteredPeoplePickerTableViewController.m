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
                    if (granted) {
                        // Refreshing.
                        [self loadContacts];
                    }
                });
            } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
                // The user has previously given access, add the contact
            } else {
                // The user has previously denied access
                // Send an alert telling user to change privacy setting in settings app
                [UIAlertView showWithTitle:NSLocalizedString(@"user_rejected_access_to_addressbook", @"Message shown when the user has previously rejected access. He'll have to go in the settings.")];
                return nil;
            }
        } else {    // we're on iOS 5
            ab = ABAddressBookCreate();
        }
        if (error) {
            NSLog(@"ABAddressBookCreateWithOptions returned error code %ld", CFErrorGetCode(*error));
        } else {
            [self loadContacts];
        }
    }
    return self;
}

#pragma - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"loading_contacts", @"The title 'Loading Contacts...' on top of the Table View while loading the contacts");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(dismiss)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
    self.mySearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.mySearchDisplayController.searchResultsDelegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL];
    }
    NSArray *array = [self arrayForTableView:tableView];
    if (array.count > indexPath.row) {
        ABRecordRef record = (__bridge_retained ABRecordRef)(array[indexPath.row]);
        CFStringRef compositeName = ABRecordCopyCompositeName(record);
        cell.textLabel.text = (__bridge NSString *)(compositeName);
        CFRelease(record);
        if (compositeName) {
            CFRelease(compositeName);
        }
    } else {
        cell.textLabel.text = @""; // This shouldn't happen, but if it does, at least we don't crash.
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id record = nil;
    if (_searchedPeople && _searchedPeople.count > indexPath.row) {
        record = _searchedPeople[indexPath.row];
    } else if (_people.count > indexPath.row) {
        record = _people[indexPath.row];
    }
    _searchedPeople = nil;
    if (record) {
        ABMultiValueRef multiValue = ABRecordCopyValue((__bridge ABRecordRef)record, kABPersonAddressProperty);
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
                [personViewController setDisplayedProperties:@[@(kABPersonAddressProperty)]];
                [self.navigationController pushViewController:personViewController animated:YES];
            }
                break;
        }
        CFRelease(multiValue);
    } else {
        DLogI(indexPath.row); // Hint to the developer that something wrong happened.
    }
}

#pragma mark - ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return [[self peoplePickerDelegate] peoplePickerNavigationController:self.filteredPeoplePickerNavigationController shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}


#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self search:searchString];
    return YES;
}

#pragma mark - Private Methods

- (void)loadContacts
{
    dispatch_async(dispatch_queue_create("biz.pomcast.mcfilteredppnc.loading", NULL), ^{
        ABRecordRef source = ABAddressBookCopyDefaultSource(ab);
        if (source) {
            _people = (__bridge_transfer NSArray *)(ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(ab, source, kABPersonSortByFirstName));
            CFRelease(source);
            
            [self logPeople];
            // Inspired from http://developer.apple.com/library/ios/#documentation/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Chapters/DirectInteraction.html#//apple_ref/doc/uid/TP40007744-CH6-SW1
            NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
                ABRecordRef recordRef = (__bridge ABRecordRef)record;
                ABMultiValueRef multiValue = ABRecordCopyValue(recordRef, kABPersonAddressProperty);
                BOOL isValid = ABMultiValueGetCount(multiValue) > 0 ? YES : NO;
                CFRelease(multiValue);
                CFStringRef name = ABRecordCopyCompositeName(recordRef);
                isValid = isValid && name;
                if (name) {
                    CFRelease(name);
                }
                return isValid;
            }];
            _people = [_people filteredArrayUsingPredicate:predicate];
            [self logPeople];
        } else {
            _people = [NSArray array]; // Hint to the developer.
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            self.title = NSLocalizedString(@"contacts", @"The title 'Contacts' on top of the Table View once the contacts have been loaded");
        });
    });
}

- (void)logPeople
{
#ifdef DEBUG
#if 0 && TARGET_IPHONE_SIMULATOR
    [_people enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DLogV((__bridge_transfer NSString*)ABRecordCopyCompositeName((__bridge ABRecordRef)(_people[idx])));
    }];
#endif
#endif
}

- (NSArray*)arrayForTableView:(UITableView*)tableView
{
    return (tableView == self.tableView) ? _people : _searchedPeople;
}

- (void)search:(NSString *)searchString
{
    NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
        CFStringRef compositeNameRef = ABRecordCopyCompositeName((__bridge ABRecordRef)record);
        NSRange range = [(__bridge NSString *)compositeNameRef rangeOfString:searchString
                                                                     options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch];
        BOOL result = range.location != NSNotFound;
        if (compositeNameRef) {
            CFRelease(compositeNameRef);
        }
        return result;
    }];
    _searchedPeople = [_people filteredArrayUsingPredicate:predicate];
}

- (void)dealloc
{
    self.people = nil;
    self.searchedPeople = nil;
    if (ab) {
        CFRelease(ab);
    }
}

@end
