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

@property (strong, nonatomic) NSArray *people;

@end

@implementation MCFilteredPeoplePickerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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

    self.title = NSLocalizedString(@"contacts", @"The title 'Contacts' on top of the Table View");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self.navigationController action:@selector(dismiss)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    CFErrorRef *error = nil;
    ABAddressBookRef ab = ABAddressBookCreateWithOptions(NULL, error);
    if (error) {
        NSLog(@"ABAddressBookCreateWithOptions returned error code %ld", CFErrorGetCode(*error));
    } else {
        _people = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(ab);
        
        // Inspired from http://developer.apple.com/library/ios/#documentation/ContactData/Conceptual/AddressBookProgrammingGuideforiPhone/Chapters/DirectInteraction.html#//apple_ref/doc/uid/TP40007744-CH6-SW1
        
        NSPredicate* predicate = [NSPredicate predicateWithBlock: ^(id record, NSDictionary* bindings) {
            ABMultiValueRef multiValue = [self multiValue:record];
            BOOL result = ABMultiValueGetCount(multiValue) > 0 ? YES : NO;
            return result;
        }];
        _people = [_people filteredArrayUsingPredicate:predicate];
    }
    CFRelease(ab);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_people count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ABRecordRef record = (__bridge ABRecordRef)(_people[indexPath.row]);
    CFStringRef compositeName = ABRecordCopyCompositeName(record);
    cell.textLabel.text = (__bridge NSString *)(compositeName);
    CFRelease(compositeName);
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
 
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
}

#pragma mark - ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return [[self peoplePickerDelegate] peoplePickerNavigationController:self.filteredPeoplePickerNavigationController shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
}


@end
