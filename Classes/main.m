#import "main.h"

int main(int argc, char **argv)
{
	NSAutoreleasePool *autoreleasePool = [
	[ NSAutoreleasePool alloc ] init
	];
	int returnCode = UIApplicationMain(argc, argv, @"MyApp", @"MyApp");
	[ autoreleasePool release ];
	return returnCode;
}

@implementation MyApp

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	window = [ [ UIWindow alloc ] initWithContentRect:
	[ UIHardware fullScreenApplicationContentRect ]
	];

	CGRect rect = [ UIHardware fullScreenApplicationContentRect ];
	rect.origin.x = rect.origin.y = 0.0f;

	mainView = [ [ MainView alloc ] initWithFrame: rect ];
	[ window setContentView: mainView ];
	[window makeKeyAndVisible];
}

- (void) applicationWillTerminate
{
	[mainView saveToFile: @"/var/mobile/Documents/lasttext.gom"];
}
@end


@implementation MainView
- (id)initWithFrame:(CGRect)rect {
	if ((self == [ super initWithFrame: rect ]) != nil) {
		CGRect viewRect;
		int i;

		/* Create a new view port below the navigation bar */
		viewRect = CGRectMake(rect.origin.x, rect.origin.y + 48.0,
		rect.size.width, rect.size.height - 48.0);

		textPage= [ [ MyTextView alloc ] initWithFrame: rect ];
		[textPage initVariables];
		
		NSString * 	input = [ [ NSString alloc ] initWithData: 
			[[ NSFileManager defaultManager ] contentsAtPath: @"/var/mobile/Documents/lasttext.gom" ]  
			encoding:NSUTF8StringEncoding ];


		[textPage setContentToHTMLString: input];
		//[textPage setContentToHTMLString: @"gomercin<div>hederoy</div>sad<font style=\"background-color:blue\">gomer <div>de <br>gomgom heleloy</font> asdsdsd as</div> "];

		[textPage setDelegate: self];
	//	[self addSubview: textPage];

	/* Create a navigation bar*/
		navBar = [ self createNavBar: rect ];
		segCtl = [ [ UISegmentedControl alloc ]
				initWithFrame:CGRectMake(85.0, 1.0, 150.0, 48.0)
				withStyle: 2
				withItems: NULL ];
		[ segCtl insertSegment:0 withTitle:@"Copy" animated: TRUE ];
		[ segCtl insertSegment:1 withTitle:@"Cut" animated: TRUE ];
		[ segCtl insertSegment:2 withTitle:@"Paste" animated: TRUE ];
		[ segCtl setDelegate:self ];
		segCtl.momentary = YES;

		[segCtl addTarget:self action:@selector(segmentAction:) forControlEvents:1 << 12];

		[ navBar addSubview: segCtl ];
		[ self addSubview: navBar ];

		currentSubView = enumTextPage;
		[self flipTo: enumTextPage];
		
		rect.size.height = rect.size.height - 48.0;

		menuView = [ [ MenuView alloc ] initWithFrame: rect ];
        	[ menuView reloadData ];
		[ menuView setSuperView: self];
        	
	

	    smsView = [ [ SMSView alloc ] initWithFrame: rect ];
		[smsView setSuperView: self];
	    notesView = [ [ NotesView alloc ] initWithFrame: rect ];
		[notesView setSuperView: self];
	
	    contactsView = [ [ ContactsView alloc ] initWithFrame: rect ];
		[contactsView setSuperView: self];
	
		smsSubPage = [ [ SMSSubPage alloc ] initWithFrame: rect ];
		[smsSubPage setSuperView: self];
		
		mailView = [[MailView alloc] initWithFrame: rect];
		[mailView setSuperView: self];
		mailSubPage = [[MailSubPage alloc] initWithFrame: rect];
		[mailSubPage setSuperView: self];


		transView = [[[UITransitionView alloc] initWithFrame:viewRect] autorelease];
		[self addSubview:transView];
	
		[transView transition:2 toView:textPage];
		[transView transition:3 toView:textPage];
	}

	return self;
}

- (void)dealloc
{
	[ navBar release ];
	[ navItem release ];
	
	[segCtl release ];
	[transView release ];

	[menuView release ];
	[smsView release ];
	[notesView release ];
	[contactsView release ];			     
	[textPage release ];
	
	[smsSubPage release ];
	[mailView release ];
	[mailSubPage release ];
	
	[ self dealloc ];
	[ super dealloc ];
}

- (UINavigationBar *)createNavBar:(CGRect)rect {
	UINavigationBar *newNav = [ [UINavigationBar alloc] initWithFrame:	CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, 48.0)	];

	[ newNav setDelegate: self ];
	[ newNav enableAnimation ];

	/* Add our title */
	navItem = [ [UINavigationItem alloc] initWithTitle:@"Copy&Paste" ];
	[ newNav pushNavigationItem: navItem ];

	[ newNav showLeftButton:@"Save"  withStyle: 0
		rightButton:@"Menu" withStyle: 0 ];

	return newNav;
}

- (void) setNavigationBarForView
{
	switch (currentSubView)
	{
		case enumTextPage: {
			[navBar showLeftButton:@"Clear"  withStyle: 0
				rightButton:@"Menu" withStyle: 0 ];
			[ navBar addSubview: segCtl ];
		}; break;

		case enumMenuView: {
			[ navBar showLeftButton:@"Text View"  withStyle: 1
				rightButton:@"About" withStyle: 0 ];

			[navItem setTitle: @"Menu"];

			[segCtl removeFromSuperview];
		}; break;

		case enumAboutView: {
			[ navBar showLeftButton:@"Menu"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"About"];
		}; break;

		case enumFileView: {
			[ navBar showLeftButton:@"Back"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select File"];
		}; break;

		case enumNotesView: {
			[ navBar showLeftButton:@"Menu"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select Note"];
		}; break;
		
		case enumContactsView: {
			[ navBar showLeftButton:@"Menu"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select Contact"];
		}; break;

		case enumSMSView: {
			[ navBar showLeftButton:@"Menu"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select SMS Group"];
		}; break;
		
		case enumSMSSubPage: {
			[ navBar showLeftButton:@"SMS Groups"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select SMS"];
		}; break;
		
		case enumMailView: {
			[ navBar showLeftButton:@"Menu"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select Mailbox"];
		}; break;
		
		case enumMailSubPage: {
			[ navBar showLeftButton:@"Mailboxes"  withStyle: 1
				rightButton:nil withStyle: 0 ];

			[navItem setTitle: @"Select Mail"];
		}; break;
	}
}

- (void)navigationBar:(UINavigationBar *)navbar buttonClicked:(int)button
{
	switch (button) {
	/* Right */
	case 0:
		{
			
			switch (currentSubView)
			{
				case enumTextPage: {
					[textPage clearSelection: 0];
					[ textPage	setFrame: CGRectMake(0.0f, 0.0f, 320.0f, [self bounds].size.height - 48) ];
					[self flipTo: enumMenuView];
				}; break;

				case enumMenuView: {
					[menuView showAboutSheet];
				}; break;

				case enumAboutView: {
		
				}; break;

				case enumFileView: {
				}; break;

				case enumNotesView: {
				}; break;

				case enumSMSView: {
				}; break;
			}

		}; break;
	/* Left */
	case 1:
		{
			switch (currentSubView)
			{
				case enumTextPage: {
				[textPage initVariables];
				//[textPage savePageToFile];
				[textPage setText:@""];
				}; break;

				case enumMenuView: {
					[textPage initVariables];
					[self flipTo: enumTextPage];
		
				}; break;

				case enumAboutView: {
					[self flipTo: enumMenuView];

				}; break;

				case enumFileView: {
					[self flipTo: enumMenuView];

				}; break;

				case enumNotesView: {
					[self flipTo: enumMenuView];

				}; break;
				
				case enumContactsView: {
					[self flipTo: enumMenuView];

				}; break;				

				case enumSMSView: {
					[self flipTo: enumMenuView];

				}; break;
				
				case enumSMSSubPage:{
					[self flipTo: enumSMSView];
				}; break;
				
				case enumMailView: {
					[self flipTo: enumMenuView];

				}; break;
				
				case enumMailSubPage:{
					[self flipTo: enumMailView];
				}
			}
		};break;
	}
}

- (void) flipTo: (enum subViews) viewToGo
{
	currentSubView = viewToGo;
	[self setNavigationBarForView];


	switch (currentSubView)
	{
		case enumTextPage: {
			[transView transition:2 toView:textPage];

		}; break;

		case enumMenuView: {
			[transView transition:1 toView:menuView];
		
		}; break;

		case enumAboutView: {

		}; break;

		case enumFileView: {

		}; break;

		case enumNotesView: {
			[ notesView reloadData ];
			[transView transition:1 toView: notesView];
		}; break;
		
		case enumContactsView: {
			[ contactsView reloadData ];
			[transView transition:1 toView: contactsView];
		}; break;

		case enumSMSView: {
			[ smsView reloadData ];
			[transView transition:1 toView: smsView];
		}; break;
		
		case enumSMSSubPage: {
			[ smsSubPage reloadData ];
			[transView transition:1 toView: smsSubPage];
		}; break;
		
		case enumMailView: {
			[ mailView reloadData ];
			[transView transition:1 toView: mailView];
		}; break;
		
		case enumMailSubPage: {
			[ mailSubPage reloadData ];
			[transView transition:1 toView: mailSubPage];
		}; break;
	}

		

}

- (void)segmentAction:(id)sender  
{ 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	int index = [segmentedControl selectedSegmentIndex];
	
	switch (index) {
	case 0:
		{
			[textPage CopyToClipboard];
		}; break;
	case 1:
		{
			[textPage CutToClipboard];
		}; break;
	case 2:
		{
			[textPage PasteFromClipboard];		
		}break;
	}
}

- (void) setTextToEdit:(NSString *) inp_text
{
	[textPage initVariables];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @"\n\r" withString: @"<br>"];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
		
	[textPage setContentToHTMLString: inp_text];
}

- (void) setHTMLToEdit:(NSString *) inp_text
{
	[textPage initVariables];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @"<div>" withString: @"<br>"];
	inp_text = [inp_text stringByReplacingOccurrencesOfString: @"</div>" withString: @"<br>"];
	[textPage setContentToHTMLString: inp_text];
}

- (NSString *) getCurrentText
{
	return [textPage text];
}

- (NSString *) getCurrentHTML
{
	return [textPage contentAsHTMLString];
}

- (void) clearSelection
{
	[textPage clearSelection:0];
}

- (void) setSMSListOwner:(NSString *) inp
{
	[smsSubPage setSender:inp];
}

- (void) setMailBox:(int) inp
{
	[mailSubPage setMailBox:inp];
}

- (void) gomerLOG:(NSString *) lg
{
	[lg
	   writeToFile: @"/var/mobile/Documents/gomerlog.txt" 
	   atomically: NO 
	   encoding: NSUTF8StringEncoding
	   error: nil];
}

- (void)loadFile:(NSString*)file
{
	NSString * currentFile = [ [ NSString alloc ] 
			initWithData: [ [ NSFileManager defaultManager ] contentsAtPath: file ] encoding:NSUTF8StringEncoding ];
			
	[ self setTextToEdit: currentFile ];
}

- (void)saveToFile:(NSString*)file
{
	[[textPage text] 
	   writeToFile: file 
	   atomically: NO 
	   encoding: NSUTF8StringEncoding
	   error: nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	[ textPage setFrame: CGRectMake(0.0f, 0.0f, 320.0f, 230.0f) ];
}


- (void)textViewDidEndEditing:(UITextView *)textView
{
	[ textPage	setFrame: CGRectMake(0.0f, 0.0f, 320.0f, [self bounds].size.height - 48) ];
}
@end
