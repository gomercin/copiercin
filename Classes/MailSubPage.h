#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import "Common.h"

@interface MailSubPage : UITable
{
    NSMutableArray *MailList;
	NSMutableArray *MailIDs;
	int mailBox;
    UITableColumn *colMailPreview;
	
	UIView *SuperView;
}
- (id)initWithFrame:(struct CGRect)rect;
- (void)reloadData;
- (int)numberOfRowsInTable:(UITable *)_table;
- (UITableCell *)table:(UITable *)table
    cellForRow:(int)row
    column:(UITableColumn *)col;
- (void)dealloc;

- (void) setSuperView: (UIView *) sv;
- (void) setMailBox: (int) mb;
@end
