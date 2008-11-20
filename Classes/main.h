#import "MyTextView.h"
#import "Menu.h"
#import "Common.h"
//#import "SMS.h"
#import "SMSView.h"
#import "NotesView.h"
#import "SMSSubPage.h"
#import "MailView.h"
#import "MailSubPage.h"
#import "ContactsView.h"

@interface MainView : UIView
{
	UINavigationBar    *navBar;    /* Our navigation bar */
	UINavigationItem   *navItem;   /* Navigation bar title */
	UISegmentedControl *segCtl;
	UITransitionView   *transView;

	enum subViews currentSubView;
	
//subviews
	MenuView	*menuView; //0
	SMSView		*smsView;  //1
	NotesView	*notesView;//2
	MyTextView  *textPage; //5
	SMSSubPage 	*smsSubPage;
	MailView 	*mailView;
	MailSubPage *mailSubPage;
	ContactsView *contactsView;

//FileTable *fileTable;

}

- (id)initWithFrame:(CGRect)frame;
- (void)dealloc;
- (UINavigationBar *)createNavBar:(CGRect)rect;
- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button;
- (void)segmentAction:(id)sender ;
- (void) setNavigationBarForView:(int) viewID;
- (void) flipTo: (enum subViews) viewToGo;
- (void)segmentAction:(id)sender;
- (void) setTextToEdit:(NSString *) inp_text;
- (void) setHTMLToEdit:(NSString *) inp_text;
- (NSString *) getCurrentText;
- (NSString *) getCurrentHTML;
- (void) clearSelection;
- (void) setSMSListOwner:(NSString *) inp;
- (void) setMailBox:(int) inp;
- (void) gomerLOG;
- (void)loadFile:(NSString*)file;
- (void)saveToFile:(NSString*)file;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;

@end

@interface MyApp : UIApplication
{
	UIWindow *window;
	MainView *mainView;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
@end
