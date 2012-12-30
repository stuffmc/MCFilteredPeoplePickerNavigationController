#MCFilteredPeoplePickerNavigationController

A drop in replacement for UIPeoplePickerNavigationController allowing to display only records having a specific value.

How to use?

    MCFilteredPeoplePickerNavigationController *nc = [[MCFilteredPeoplePickerNavigationController alloc] init];
    [nc setPeoplePickerDelegate:self];
    [self presentViewController:nc animated:YES completion:^{    }];

Delegate?

Yup, you'll have to implement `MCFilteredPickerNavigationControllerDelegate`

	- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
	- (BOOL)peoplePickerNavigationController:(MCFilteredPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
	
Those methods look familiar?! Yes, they are the same as those from `ABPeoplePickerNavigationControllerDelegate`.


License
---

```

 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you want to support me, come to [Objctive-Cologne](http://ObjCGN.com) or buy [Disk Alarm](http://diskalarm.com) :-)
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 ```