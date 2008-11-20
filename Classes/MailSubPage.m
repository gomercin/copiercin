#import "MailSubPage.h"
#import <sqlite3.h>

@implementation MailSubPage

- (id)initWithFrame:(struct CGRect)rect {
    if ((self == [ super initWithFrame: rect ]) != nil) {

        colMailPreview = [ [ UITableColumn alloc ]
            initWithTitle: @"MailPreview"
            identifier:@"mailpreview"
            width: rect.size.width
        ];
        [ self addTableColumn: colMailPreview ];

        [ self setSeparatorStyle: 2 ];
        [ self setDelegate: self ];
        [ self setDataSource: self ];
        [ self setRowHeight: 48 ];

        MailList = [ [ NSMutableArray alloc] init ];
		MailIDs  = [ [ NSMutableArray alloc] init ];
    }

    return self;
}

- (void) reloadData {
    [ MailList removeAllObjects ];
	[ MailIDs removeAllObjects];
    
		/*********bas: SQLITE hedeleri***/

		sqlite3 *database;
		int intID;
		NSNumber *currentMailID;
		
		NSString *noteText = @"empty";
		NSString *path = @"/var/mobile/Library/Mail/Envelope Index";
		NSString *sql = [NSString stringWithFormat: 
				@"SELECT * FROM messages WHERE mailbox='%d' ORDER BY sort_order DESC", 
				mailBox+1];
					
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			sqlite3_stmt *statement ;
			
			if (sqlite3_prepare(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
			{
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					if(sqlite3_column_text(statement, 3) != nil)
					{
						noteText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 3)];
						[ MailList addObject: noteText	];
						
						intID = sqlite3_column_int(statement, 0);
						currentMailID = [[NSNumber alloc] initWithInt: intID];
						[ MailIDs addObject: currentMailID];
					}
				}
			}
			sqlite3_finalize(statement);
		}
		
		sqlite3_close(database);


		/*********bit: SQLITE hedeleri***/	
	
	

    [ super reloadData ];
}

- (int)numberOfRowsInTable:(UITable *)_table {
    return [ MailList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{	  
		UISimpleTableCell *cell = [ [ UISimpleTableCell alloc ] init ];

        [ cell setTitle: [ MailList objectAtIndex: row ] ];
        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {

	int selected = [ self selectedRow ];
    NSString *selectedMailSubject = [ MailList objectAtIndex:  selected];
	NSNumber *selectedMailID = [MailIDs objectAtIndex: selected];
	
		/*********bas: SQLITE hedeleri***/

		sqlite3 *database;
		NSString *mailText = @"empty";
		NSString *path = @"/var/mobile/Library/Mail/Envelope Index";
		NSString *sql = [NSString stringWithFormat: 
				@"SELECT * FROM message_data WHERE message_id='%d' AND part='summary'", 
				[selectedMailID intValue] ];
				
		// [SuperView setTextToEdit: sql];
		// return;
					
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			sqlite3_stmt *statement ;
			
			if (sqlite3_prepare(database, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) 
			{
				if (sqlite3_step(statement) == SQLITE_ROW) 
				{
					if(sqlite3_column_text(statement, 5) != nil)
					{
						mailText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 5)];
						mailText = [NSString stringWithFormat: @"Subject: %@ \n\r %@", selectedMailSubject, mailText];
					}
					else
					{
						mailText = @"Selected mail's content could not be retrieved";
					}
				}
				else
				{
						mailText = @"Selected mail's content could not be retrieved";
				}
			}
			sqlite3_finalize(statement);
		}
		
		sqlite3_close(database);


		/*********bit: SQLITE hedeleri***/	
	

    
	[SuperView setHTMLToEdit: mailText];
	[SuperView flipTo: enumTextPage];
	
}

- (void)dealloc {
    [ colMailPreview release ];
    [ MailList release ];
	[ MailIDs release ];
	[ SuperView release ];
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}

- (void) setMailBox: (int) inp
{
	mailBox = inp;
}
@end
