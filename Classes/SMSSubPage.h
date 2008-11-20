#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import "Common.h"

@interface SMSSubPage : UITable
{
    NSMutableArray *SMSList;
		NSString *senderAddress;
    UITableColumn *colSMSPreview;
	
	UIView *SuperView;
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
- (void) setSender: (NSString *) from;
@end
