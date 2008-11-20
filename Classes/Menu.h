#import <UIKit/UIKit.h>
#import <UIKit/UIPreferencesTable.h>
#import <UIKit/UIPreferencesTextTableCell.h>
#import <UIKit/UISwitchControl.h>
#import <UIKit/UISegmentedControl.h>
#import <UIKit/UISliderControl.h>
#import "Common.h"

#define NUM_GROUPS 3
#define CELLS_PER_GROUP 5

@interface MenuView : UIPreferencesTable
{
    UIPreferencesTableCell *cells[NUM_GROUPS][CELLS_PER_GROUP];
    UIPreferencesTableCell *groupcell[NUM_GROUPS];

    UIView *SuperView;
	UIAlertSheet* saveSheet;
	UIAlertSheet* loadSheet;
	UIAlertSheet* aboutSheet;
}

- (id)initWithFrame:(CGRect)rect;
- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable;
- (UIPreferencesTableCell *)preferencesTable:
    (UIPreferencesTable *)aTable
    cellForGroup:(int)group;
- (float)preferencesTable:(UIPreferencesTable *)aTable
    heightForRow:(int)row
    inGroup:(int)group
    withProposedHeight:(float)proposed;
- (BOOL)preferencesTable:(UIPreferencesTable *)aTable
    isLabelGroup:(int)group;
- (UIPreferencesTableCell *)preferencesTable:
    (UIPreferencesTable *)aTable
    cellForRow:(int)row
    inGroup:(int)group;

- (void) setSuperView: (UIView *) sv;
- (void) showLoadFileSheet;
- (void) prepareAndLaunchSMS;
- (void) saveTextAsNewNote;
- (void) prepareAndLaunchMail;
- (void) showSaveFileSheet;
- (void) showAboutSheet;
- (void) tableRowSelected:(NSNotification*)notification;
- (void) alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button;
- (void) dealloc;
@end


