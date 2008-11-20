#import "ContactsView.h"
#import <sqlite3.h>
#import <AddressBook/AddressBook.h>

@implementation ContactsView

- (id)initWithFrame:(struct CGRect)rect {
    if ((self == [ super initWithFrame: rect ]) != nil) {

        colContactName = [ [ UITableColumn alloc ]
            initWithTitle: @"ContactsPreview"
            identifier:@"contactspreview"
            width: rect.size.width
        ];
        [ self addTableColumn: colContactName ];

        [ self setSeparatorStyle: 1 ];
        [ self setDelegate: self ];
        [ self setDataSource: self ];
        [ self setRowHeight: 48 ];

        ContactsList = [ [ NSMutableArray alloc] init ];
        contactNames = [ [ NSMutableArray alloc] init ];
		
		contactsAreLoaded = NO;
    }

    return self;
}

- (void) reloadData {
    //[ ContactsList removeAllObjects ];
    // [ contactNames removeAllObjects ];
	
	if (contactsAreLoaded == YES) return;

	contactsAreLoaded = YES;
//	NSMutableArray *list = [[NSMutableArray alloc] init];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	
	NSArray *addresses = (NSArray *) ABAddressBookCopyArrayOfAllPeople(addressBook);
	int addressesCount = [addresses count];
	
	for (int i = 0; i < addressesCount; i++) {
		ABRecordRef record = [addresses objectAtIndex:i];

		NSString *tableEntry = @"";
		NSString *fullInfo = @"";
		
		//Get name
		NSMutableString *contactName = (NSMutableString *)ABRecordCopyCompositeName(record);
		if (contactName != nil)
		{
			contactName = [NSString stringWithFormat: @"%@", contactName];
			tableEntry = contactName;
			fullInfo = [fullInfo stringByAppendingString: [NSString stringWithFormat: @"%@ ", contactName]];
		}
		
		//Get phone numbers
		ABMultiValueRef phoneNumbers =(NSString*)ABRecordCopyValue(record,kABPersonPhoneProperty);
		NSString* mobile=@"";
		for(int j=0;j<ABMultiValueGetCount(phoneNumbers);j++)
		{
			mobile=(NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers,j);
			fullInfo = [fullInfo stringByAppendingString: [NSString stringWithFormat: @"%@ ", mobile]];			
			
			if ([tableEntry isEqualToString:@""] == YES)
				tableEntry = mobile;
		}
		
		//Get eMail addresses
		ABMultiValueRef emailAddresses =(NSString*)ABRecordCopyValue(record,kABPersonEmailProperty);
		for(int j=0;j<ABMultiValueGetCount(emailAddresses);j++)
		{
			NSString* email=@"";
			email=(NSString*)ABMultiValueCopyValueAtIndex(emailAddresses,j);
			fullInfo = [fullInfo stringByAppendingString: [NSString stringWithFormat: @"%@ ", email]];			
			
			if ([tableEntry isEqualToString:@""] == YES)
				tableEntry = email;
		}
		
		//Get Street Addresses
		ABMutableMultiValueRef multiValue = ABRecordCopyValue(record, kABPersonAddressProperty);
		for(CFIndex k=0;k<ABMultiValueGetCount(multiValue);k++)
		{
				CFDictionaryRef dict = ABMultiValueCopyValueAtIndex(multiValue, k);
				CFStringRef street = CFDictionaryGetValue(dict, kABPersonAddressStreetKey);
				CFStringRef city = CFDictionaryGetValue(dict, kABPersonAddressCityKey);
				CFStringRef country = CFDictionaryGetValue(dict, kABPersonAddressCountryKey);	
				CFRelease(dict);
				
				if (street == nil) street = @"";
				if (city == nil) city = @"";
				if (country == nil) country = @"";

				NSString *address = [NSString stringWithFormat:@"%@ %@ %@",street,city,country];
				
				fullInfo = [fullInfo stringByAppendingString: [NSString stringWithFormat: @"%@ ", address]];
			
				if ([tableEntry isEqualToString:@""] == YES)
					tableEntry = address;
		}
		
		[contactNames addObject: tableEntry];
		[ContactsList addObject: fullInfo];
	}
	
    [ super reloadData ];
}

- (int)numberOfRowsInTable:(UITable *)_table {
    return [ ContactsList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{
        UIImageAndTextTableCell *cell = [ [ UIImageAndTextTableCell alloc ] init ];
        //[ cell setTable: self ];
		
		contactsIcon = [[ UIImage imageAtPath:@"/Applications/MobileAddressBook.app/icon.png" ] 
							_imageScaledToSize:CGSizeMake(40.0f, 40.0f) interpolationQuality:1];
		[cell setImage: contactsIcon ];

        [ cell setTitle: [ contactNames objectAtIndex: row ] ];

        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {

    NSString *selectedText = [ ContactsList objectAtIndex: [ self selectedRow ] ];
		
	[SuperView setTextToEdit: selectedText];
	[SuperView flipTo: enumTextPage];
}

- (void)dealloc {
    [ colContactName release ];
    [ ContactsList release ];
	[ contactNames release ];
	[ SuperView release ];
	[ contactsIcon release ];
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}
@end
