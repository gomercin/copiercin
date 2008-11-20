#import "SMSView.h"
#import <sqlite3.h>
#import <Foundation/Foundation.h>

@implementation SMSView

- (id)initWithFrame:(struct CGRect)rect {
    if ((self == [ super initWithFrame: rect ]) != nil) {

        colSMSPreview = [ [ UITableColumn alloc ]
            initWithTitle: @"SMSPreview"
            identifier:@"smspreview"
            width: rect.size.width
        ];
        [ self addTableColumn: colSMSPreview ];

        [ self setSeparatorStyle: 2 ];
        [ self setDelegate: self ];
        [ self setDataSource: self ];
        [ self setRowHeight: 48 ];

        SMSAddressList = [ [ NSMutableArray alloc] init ];
		SMSAddressOwnerList = [ [ NSMutableArray alloc] init ];
		
		smsSendersAreLoaded = NO;
    }

    return self;
}
- (void) smsLOG:(NSString *)lg
{
	// FILE *outfile;
	// outfile = fopen("/var/mobile/Documents/smslog.txt", "a");
	// fprintf(outfile, "%s\n", [lg UTF8String]);
	// fclose(outfile);
}

- (void) reloadData {
    //[ SMSAddressList removeAllObjects ];
	//[ SMSAddressOwnerList removeAllObjects ];
	
	if (smsSendersAreLoaded == YES) return;

		smsSendersAreLoaded = YES;
    
		sqlite3 *database;
		int currentSMSid;
		NSString *smsSender = @"empty";
		NSString *path = @"/var/mobile/Library/SMS/sms.db";

		
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT * FROM group_member WHERE 1";
			sqlite3_stmt *statement ;
			
			/****begin finding numbers****/
			if (sqlite3_prepare(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					if(sqlite3_column_text(statement, 2) != nil)
					{
						smsSender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
					
						[ SMSAddressList addObject: smsSender ];
					}
				}
			}
			sqlite3_finalize(statement);
			sqlite3_close(database);
			/****end finding numbers****/
			
									
			/********find the real names************/
			
			path = @"/var/mobile/Library/AddressBook/AddressBook.sqlitedb";
			if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
			{					
				NSString *lastFour;// = [[NSString alloc] init];
				NSString *realName;// = [[NSString alloc] init];
				NSEnumerator *forEach = [SMSAddressList objectEnumerator];
				
				NSMutableArray* IDsWithSameLastFourDigit = [ [ NSMutableArray alloc] init ];
				
				NSString *currentSender = @"";
				int found = 0;
				
				while (currentSender = [forEach nextObject])
				{
					//[self smsLOG:@"currentSender:"];
					//[self smsLOG: currentSender];
				
					[IDsWithSameLastFourDigit removeAllObjects];
					found = 0;
					if ([currentSender length] >= 4)
						lastFour = [currentSender substringFromIndex:([currentSender length] - 4)];
					else //3 digit caller?
						lastFour = currentSender;
						
					NSString *strippedSender = [currentSender stringByReplacingOccurrencesOfString:@" " withString: @""];
					strippedSender = [strippedSender stringByReplacingOccurrencesOfString:@"+" withString: @""];
					strippedSender = [strippedSender stringByReplacingOccurrencesOfString:@"-" withString: @""];
					strippedSender = [strippedSender stringByReplacingOccurrencesOfString:@")" withString: @""];
					strippedSender = [strippedSender stringByReplacingOccurrencesOfString:@"(" withString: @""];
					
					//get the last 8 characters, hmm, let's make it 7 :)
					if ([strippedSender length] >= 7)
						strippedSender = [strippedSender substringFromIndex:([strippedSender length] - 7)];
					
					int strippedSenderLength = [strippedSender length];
						
					//[self smsLOG:@"strippedSender:"];	
					//[self smsLOG: strippedSender];
					
					NSString * subSql = [NSString stringWithFormat:@"SELECT * FROM ABPhoneLastFour WHERE value='%@'", lastFour];
					int subID;
					
					sqlite3_stmt *subStatement;
					if (sqlite3_prepare(database, [subSql UTF8String], -1, &subStatement, NULL) == SQLITE_OK)
					{
						//it is possible to have more than 1 values with same last-four digits
						while(sqlite3_step(subStatement) == SQLITE_ROW)
						{
							int recordIDByLastFourDigit;
							if(sqlite3_column_int(subStatement, 0) != nil)
							{
								recordIDByLastFourDigit = sqlite3_column_int(subStatement, 0);
								[IDsWithSameLastFourDigit addObject: [NSNumber numberWithInt: recordIDByLastFourDigit]];
							}
						}
						
						//no matching numbers are found, then name is set as the number
						if ( [IDsWithSameLastFourDigit count] == 0 )
						{
							found = 0;
						}
						//if there are at least 1 matching last4digits, we will proceed in the next stage to find if it is an exact match
						else
						{
							found = 1;
						}
					}
					sqlite3_finalize(subStatement);
					
					if ( found == 1) //there is a matching last 4 digit
					{
						found = 0;
						int record_id;
						NSEnumerator *lastFourDigitEnumerator = [IDsWithSameLastFourDigit objectEnumerator];
						while (subID = [[lastFourDigitEnumerator nextObject] intValue])
						{
							subSql = [NSString stringWithFormat:@"SELECT * FROM ABMultiValue WHERE UID=%d", subID];
							if (sqlite3_prepare(database, [subSql UTF8String], -1, &subStatement, NULL) == SQLITE_OK)
							{
								if(sqlite3_step(subStatement) == SQLITE_ROW)
								{
									if(sqlite3_column_text(subStatement, 5) != nil)
									{
										NSString *phoneNumberForCurrentRecord =  [NSString stringWithUTF8String:(char *)sqlite3_column_text(subStatement, 5)];
										
										phoneNumberForCurrentRecord = [phoneNumberForCurrentRecord stringByReplacingOccurrencesOfString:@" " withString: @""];
										phoneNumberForCurrentRecord = [phoneNumberForCurrentRecord stringByReplacingOccurrencesOfString:@"+" withString: @""];
										phoneNumberForCurrentRecord = [phoneNumberForCurrentRecord stringByReplacingOccurrencesOfString:@"-" withString: @""];
										phoneNumberForCurrentRecord = [phoneNumberForCurrentRecord stringByReplacingOccurrencesOfString:@")" withString: @""];
										phoneNumberForCurrentRecord = [phoneNumberForCurrentRecord stringByReplacingOccurrencesOfString:@"(" withString: @""];
										
										//[self smsLOG:@"phoneNumberForCurrentRecord:"];
										//[self smsLOG: phoneNumberForCurrentRecord];
										
										int comparisonLength;
										NSRange foundRange;
										if (strippedSenderLength <= [phoneNumberForCurrentRecord length])
										{
											foundRange = [phoneNumberForCurrentRecord rangeOfString: strippedSender];
										}
										else
										{
											foundRange = [strippedSender rangeOfString: phoneNumberForCurrentRecord];
										}
										
										if ( foundRange.location != NSNotFound ) //result matches, no need to look further, hopefully :)
										{
											if(sqlite3_column_int(subStatement, 1) != nil)
											{
												record_id = sqlite3_column_int(subStatement, 1);
												found = 1;
												break;
											}
										}
									}
								}
							}
							sqlite3_finalize(subStatement);
						}
						
						//what happens found is 0 here?, that's where the application crashes I assume
						if (found == 1)
						{
							found = 0;
							subSql = [NSString stringWithFormat:@"SELECT * FROM ABPerson WHERE ROWID=%d", record_id];
							if (sqlite3_prepare(database, [subSql UTF8String], -1, &subStatement, NULL) == SQLITE_OK)
							{
								if(sqlite3_step(subStatement) == SQLITE_ROW)
								{
									NSString *firstName=@"";
									NSString *lastName = @"";
									if(sqlite3_column_text(subStatement, 1) != nil)
									{
										firstName= [NSString stringWithUTF8String:(char *)sqlite3_column_text(subStatement, 1)];
									}
									
									if(sqlite3_column_text(subStatement, 2) != nil)
									{
										lastName= [NSString stringWithUTF8String:(char *)sqlite3_column_text(subStatement, 2)];
									}
									
									realName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
									
									//[self smsLOG:@"realName:"];
									//[self smsLOG: realName];
								}
							}
							sqlite3_finalize(subStatement);
						}
						else
						{
							realName = currentSender;
						}
	
					}
					else
					{
						realName = currentSender;
						
						//[self smsLOG:@"real name not found:"];
						//[self smsLOG: realName];
					}
					
					[SMSAddressOwnerList addObject: realName];
					
				}
			/*******found the real names************/
			}
			sqlite3_close(database);
		}
   [ super reloadData ];
}

- (int)numberOfRowsInTable:(UITable *)_table {
    return [ SMSAddressList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{
		UIImageAndTextTableCell *cell = [ [ UIImageAndTextTableCell alloc ] init ];
		
		smsIcon = [[ UIImage imageAtPath:@"/Applications/MobileSMS.app/icon.png" ] 
							_imageScaledToSize:CGSizeMake(40.0f, 40.0f) interpolationQuality:1];
		[cell setImage: smsIcon ];

        [ cell setTitle: [ SMSAddressOwnerList objectAtIndex: row ] ];
        [ cell setShowDisclosure: YES ];
        [ cell setDisclosureStyle: 3 ];

        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {
    NSString *selectedText = [ SMSAddressList objectAtIndex: [ self selectedRow ] ];

    /* A file was selected. Do something here. */
	[SuperView setSMSListOwner: selectedText];
	[SuperView flipTo: enumSMSSubPage];
	
}

- (void)dealloc {
    [ colSMSPreview release ];
    [ SMSAddressList release ];
	
	[ SMSAddressOwnerList release ];
	
	[ SuperView release ];
	[ smsIcon release ];
	
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}
@end
