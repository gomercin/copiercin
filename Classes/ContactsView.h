#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import "Common.h"

@interface ContactsView : UITable
{
    NSMutableArray *ContactsList;
	NSMutableArray *contactNames;
    UITableColumn *colContactName;
	
	UIView * SuperView;
	UIImageView *contactsIcon;
	
	bool contactsAreLoaded;
}
- (id)initWithFrame:(struct CGRect)rect;
- (void)reloadData;
- (int)numberOfRowsInTable:(UITable *)_table;
- (UITableCell *)table:(UITable *)table
    cellForRow:(int)row
    column:(UITableColumn *)col;
- (void)dealloc;
- (void)tableRowSelected:(NSNotification *)notification;
- (void) setSuperView: (UIView *) sv;
@end
