#import "NotesView.h"
#import <sqlite3.h>

@implementation NotesView

- (id)initWithFrame:(struct CGRect)rect {
    if ((self == [ super initWithFrame: rect ]) != nil) {

        colNotesPreview = [ [ UITableColumn alloc ]
            initWithTitle: @"NotesPreview"
            identifier:@"Notespreview"
            width: rect.size.width
        ];
        [ self addTableColumn: colNotesPreview ];

        [ self setSeparatorStyle: 1 ];
        [ self setDelegate: self ];
        [ self setDataSource: self ];
        [ self setRowHeight: 48 ];

        NotesList = [ [ NSMutableArray alloc] init ];
    }

    return self;
}

- (void) reloadData {
    [ NotesList removeAllObjects ];

		/*********bas: SQLITE hedeleri***/

		sqlite3 *database;
		int notlar;
		NSString *noteText = @"empty";
		NSString *path = @"/var/mobile/Library/Notes/notes.db";
		if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
		{
			const char *sql = "SELECT * FROM note_bodies WHERE 1 ORDER BY note_id DESC";
			sqlite3_stmt *statement ;
			
			if (sqlite3_prepare(database, sql, -1, &statement, NULL) == SQLITE_OK) 
			{
				while (sqlite3_step(statement) == SQLITE_ROW) 
				{
					//IDs[notlar] = sqlite3_column_int(statement, 0);
					if(sqlite3_column_text(statement, 1) != nil)
					{
						noteText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];

						[ NotesList addObject: noteText	];
						//[ noteIDs addObject: sqlite3_column_int(statement, 0)];
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
    return [ NotesList count ];
}

- (UITableCell *)table:(UITable *)table
  cellForRow:(int)row
  column:(UITableColumn *)col
{
        UIImageAndTextTableCell *cell = [ [ UIImageAndTextTableCell alloc ] init ];
        //[ cell setTable: self ];
		
		notesIcon = [[ UIImage imageAtPath:@"/Applications/MobileNotes.app/icon.png" ] 
							_imageScaledToSize:CGSizeMake(40.0f, 40.0f) interpolationQuality:1];
		[cell setImage: notesIcon ];

        [ cell setTitle: [ NotesList objectAtIndex: row ] ];

        return [ cell autorelease ];
}

- (void)tableRowSelected:(NSNotification *)notification {

    NSString *selectedText = [ NotesList objectAtIndex: [ self selectedRow ] ];
		
    /* A file was selected. Do something here. */
	[SuperView setHTMLToEdit: selectedText];
	[SuperView flipTo: enumTextPage];
}

- (void)dealloc {
    [ colNotesPreview release ];
    [ NotesList release ];
	[ noteIDs release ];
	[ SuperView release ];
	[ notesIcon release ];
    [ super dealloc ];
}

- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}
@end
