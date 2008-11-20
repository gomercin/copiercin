#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import "Common.h"
#import "MailSubPage.h"

@interface MailView : UITable
{
   // NSMutableArray *SMSAddressOwnerList;
	NSMutableArray *MailAddressList;
    UITableColumn *colMailPreview;
	
	UIView *SuperView;
	UIImageView *mailIcon;
}
- (id)initWithFrame:(struct CGRect)rect;
- (void)reloadData;
- (int)numberOfRowsInTable:(UITable *)_table;
- (UITableCell *)table:(UITable *)table
    cellForRow:(int)row
    column:(UITableColumn *)col;
- (void)dealloc;

- (void) setSuperView: (UIView *) sv;
@end
