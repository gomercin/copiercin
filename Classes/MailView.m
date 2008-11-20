#import "MailView.h"
#import <sqlite3.h>
#import <UIKit/UIFont.h>
#import <UIKit/UIColor.h>

@implementation MailView

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

        MailAddressList = [ [ NSMutableArray alloc] init ];
    }
    return self;
}

- (void) reloadData {
    [ MailAddressList removeAllObjects ];
    
		sqlite3 *database;
		int currentMailid;
		NSString *noteText = @"empty";
		NSString *path = @"/var/mobile/Library/Mail/Envelope Index";
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT * FROM mailboxes WHERE 1";
			sqlite3_stmt *statement ;
			
			if (sqlite3_prepare(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					if(sqlite3_column_text(statement, 1) != nil)
					{
						noteText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
					
						[ MailAddressList addObject: noteText	];
					}
				}
			}
			sqlite3_finalize(statement);
		}
		
		sqlite3_close(database);

    [ super reloadData ];
}

- (int)numberOfRowsInTable:(UITable *)_table {
    return [ MailAddressList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{
		UIImageAndTextTableCell *cell = [ [ UIImageAndTextTableCell alloc ] init ];
		
		mailIcon = [[ UIImage imageAtPath:@"/Applications/MobileMail.app/icon.png" ] 
							_imageScaledToSize:CGSizeMake(40.0f, 40.0f) interpolationQuality:1];
		[cell setImage: mailIcon ];
		
		NSString *fullMailBoxName = [ MailAddressList objectAtIndex: row ];
		NSArray *subs = [fullMailBoxName componentsSeparatedByString:@"/"];
		NSString *strippedMailBoxName = [ subs objectAtIndex: [subs count]-1];

		   [ cell setTitle: strippedMailBoxName];
	
        [ cell setShowDisclosure: YES ];
        [ cell setDisclosureStyle: 3 ];

        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {
   // NSString *selectedText = [ MailAddressList objectAtIndex: [ self selectedRow ] ];

    /* A file was selected. Do something here. */
	[SuperView setMailBox: [ self selectedRow ]];
	[SuperView flipTo: enumMailSubPage];
	
}

- (void)dealloc {
    [ colMailPreview release ];
    [ MailAddressList release ];
	[ mailIcon release];
	[ SuperView release ];
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}
@end
