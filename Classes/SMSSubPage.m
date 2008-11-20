#import "SMSSubPage.h"
#import <sqlite3.h>

@implementation SMSSubPage

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

        SMSList = [ [ NSMutableArray alloc] init ];
    }

    return self;
}

- (void) reloadData {
    [ SMSList removeAllObjects ];
    
		/*********bas: SQLITE hedeleri***/

		sqlite3 *database;
		int currentSMSid;
		NSString *noteText = @"empty";
		NSString *path = @"/var/mobile/Library/SMS/sms.db";
		NSString *sql = [NSString stringWithFormat: 
				@"SELECT * FROM message WHERE address='%@' ORDER BY date DESC", 
				senderAddress];
					
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
					
						[ SMSList addObject: noteText	];
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
    return [ SMSList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{
        UISimpleTableCell *cell = [ [ UISimpleTableCell alloc ] init ];
        //[ cell setTable: self ];

        [ cell setTitle: [ SMSList objectAtIndex: row ] ];
        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {
    NSString *selectedText = [ SMSList objectAtIndex: [ self selectedRow ] ];

    /* A file was selected. Do something here. */
	[SuperView setTextToEdit: selectedText];
	[SuperView flipTo: enumTextPage];
	
}

- (void)dealloc {
    [ colSMSPreview release ];
    [ SMSList release ];
	
	[ senderAddress release ];
	
	[ SuperView release ];
	
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}

- (void) setSender: (NSString *) inp
{
	senderAddress = inp;
}
@end
