#import <UIKit/UIKit.h>
#import <UIKit/UISimpleTableCell.h>
#import <UIKit/UITableColumn.h>
#import "Common.h"
#import "SMSSubPage.h"

@interface SMSView : UITable
{
    NSMutableArray *SMSAddressOwnerList;
		NSMutableArray *SMSAddressList;
    UITableColumn *colSMSPreview;
	
	UIView *SuperView;
	UIImageView *smsIcon;
	
	bool smsSendersAreLoaded;
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
