#import "Menu.h"
#import <sqlite3.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSCharacterSet.h>
#import <CoreFoundation/CFURL.h>

@implementation MenuView

- (id)initWithFrame:(CGRect)rect {
    if ((self == [ super initWithFrame: rect ]) != nil) {
        int i, j;

        for(i=0;i<NUM_GROUPS;i++) {
            groupcell[i] = NULL;
            for(j=0;j<CELLS_PER_GROUP;j++)
                cells[i][j] = NULL;
        }

        [ self setDataSource: self ];
        [ self setDelegate: self ];
    }

    return self;
}

- (int)numberOfGroupsInPreferencesTable:(UIPreferencesTable *)aTable {

    /* Number of logical groups, including labels */
    return NUM_GROUPS;
}

 - (int)preferencesTable:(UIPreferencesTable *)aTable
    numberOfRowsInGroup:(int)group
{
    switch (group) {
        case(0):
            return 5;
            break;
        case(1):
            return 5;
            break;
        case(2):
            return 1; /* Text label group */
            break;
    }
}

- (UIPreferencesTableCell *)preferencesTable:
    (UIPreferencesTable *)aTable
    cellForGroup:(int)group
{
     if (groupcell[group] != NULL)
         return groupcell[group];

     groupcell[group] = [ [ UIPreferencesTableCell alloc ] init ];
     switch (group) {
         case (0):
             [ groupcell[group] setTitle: @"Import text from" ];
             break;
         case (1):
             [ groupcell[group] setTitle: @"Export text as" ];
             break;
     }
     return groupcell[group];
}

- (float)preferencesTable:(UIPreferencesTable *)aTable
    heightForRow:(int)row
    inGroup:(int)group
    withProposedHeight:(float)proposed
{
    return 48;
}

- (BOOL)preferencesTable:(UIPreferencesTable *)aTable
    isLabelGroup:(int)group
{
   // if (group == 2)
    //    return YES;
    return NO;
}

- (UIPreferencesTableCell *)preferencesTable:
    (UIPreferencesTable *)aTable
    cellForRow:(int)row
    inGroup:(int)group
{
    UIPreferencesTextTableCell *cell;
//UIPreferencesTableCell *cell;

    if (cells[group][row] != NULL)
        return cells[group][row];

 //   cell = [ [ UIPreferencesTableCell alloc ] init ];

	cell = [[UIPreferencesTextTableCell alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 300.0f, 48.0f)];

 //   [ cell setEnabled: YES ];

    switch (group) {
        case (0):
            switch (row) {
                case (0):
					{
						[ cell setTitle:@"SMS" ];
						[cell setShowDisclosure:YES];
						[cell setDisclosureStyle: 2];
					}; break;
				
				case (1):
					{
						[ cell setTitle:@"Contacts" ];
						[cell setShowDisclosure:YES];
						[cell setDisclosureStyle: 2];
					}; break;
					
                case (2):
					{
						[ cell setTitle:@"Notes" ];
						[cell setShowDisclosure:YES];
						[cell setDisclosureStyle: 2];
                    }; break;
                case (3):
                    {
						[ cell setTitle:@"E-Mails" ];
						[cell setShowDisclosure:YES];
						[cell setDisclosureStyle: 2];
                    }; break;
                case (4):
					{
						[ cell setTitle:@"Regular Files" ];
                    }; break;
           } break;
        case (1):
            switch (row) {
                case (0):
					{
						[ cell setTitle:@"New SMS" ];
                    }; break;
                case (1):
                    {
						[ cell setTitle:@"New Note" ];
                    }; break;
                case (2):
                    {
						[ cell setTitle:@"New E-Mail" ];
                    }; break;
								case (3):
                    {
						[ cell setTitle:@"New Safari Object" ];
                    }; break;
                case (4):
                    {
						[ cell setTitle:@"Regular File" ];
					}; break;
            } break;
        case (2):
            [ cell setTitle: @"About" ];
            break;
    }

	[cell setValue:nil];
	[cell setDisclosureClickable: NO];
	[[cell textField] setEnabled:NO];

	[ cell setShowSelection: YES ];
	[ cell setShowSelectionNoRedisplay: YES];
	cells[group][row] = cell;

    return cell;
}


- (void) setSuperView: (UIView *) sv
{
	SuperView = sv;
}

- (void) showLoadFileSheet
{
	loadSheet = [ [ UIAlertSheet alloc ] init ];
	[ loadSheet setTitle:@"Load File" ];
	[ loadSheet setBodyText:@"Please enter full path to the file you want to load" ];
	[ loadSheet setContext:@"_loadSheet" ];
	[ loadSheet addButtonWithTitle:@"Load" ];
	[ loadSheet addButtonWithTitle:@"Cancel" ];
	[ loadSheet setDelegate: self ];
	[ loadSheet setNumberOfRows: 1 ];
	[ loadSheet addTextFieldWithValue:nil label:@"ex: /var/mobile/test.txt" ];
	[ loadSheet popupAlertAnimated: YES ];
}

-(void) prepareAndLaunchSMS
{
	NSString * currentText = [SuperView getCurrentText];
	
	currentText = [currentText stringByReplacingOccurrencesOfString: @"&" withString: @"&amp;"];
	currentText = [currentText stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
	currentText = [currentText stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
	
	NSMutableDictionary *SMSdict = [[NSMutableDictionary alloc] init];
	NSData *plistData;
	NSData *mobilePlistData;
	NSMutableDictionary *mobileSMSdict = [[NSMutableDictionary alloc] init];
	NSString *error;
	BOOL launchBiteSMS = NO;
	
	mobileSMSdict = [mobileSMSdict initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.apple.MobileSMS.plist"];	
	if (!mobileSMSdict)
	{
		NSString *MobileSMSText = [NSString stringWithFormat:
		@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
		<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n\
		<plist version=\"1.0\">\n\
		<dict>\
			<key>ComposingNewMessage</key>\
				<true/>\
			<key>SuspendedText</key>\
				<string>%@</string>\
			<key>UISuspendedSettings</key>\
				<dict>\
					<key>UISuspendedDefaultPNGKey</key>\
						<string>Default</string>\
				</dict>\
			<key>WebKitPluginsEnabled</key>\
				<false/>\
		</dict>\
		</plist>", currentText];
		
		[MobileSMSText 
	   writeToFile: @"/var/mobile/Library/Preferences/com.apple.MobileSMS.plist" 
	   atomically: NO 
	   encoding: NSUTF8StringEncoding
	   error: nil];
	}
	else
	{
		CFBooleanRef val = kCFBooleanTrue;
		[mobileSMSdict setValue:currentText forKey:@"SuspendedText"];		
		[mobileSMSdict setValue:val forKey:@"ComposingNewMessage"];		
		[mobileSMSdict setValue:nil forKey:@"SuspendedRecipients"];		
		 
		mobilePlistData = [NSPropertyListSerialization dataFromPropertyList:mobileSMSdict
		                                    format:NSPropertyListBinaryFormat_v1_0
		                                    errorDescription:&error];
		if(mobilePlistData)
		{
		    [mobilePlistData writeToFile:@"/var/mobile/Library/Preferences/com.apple.MobileSMS.plist" atomically:YES];
		}
	}



	SMSdict = [SMSdict initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bitesms.plist"];
	
	if(!SMSdict)
	{
		//plist does not exist, create it with default values. 
		SMSdict = [[NSMutableDictionary alloc] init];
	}
	else if ([[SMSdict objectForKey:@"biteDefaultApp"] boolValue])
	{
		launchBiteSMS = YES;
	}
	NSMutableArray *transitionStackValues = [[NSMutableArray alloc] init];
	
	[transitionStackValues addObject: [NSNumber numberWithInt: 0]];
	[transitionStackValues addObject: [NSNumber numberWithInt: 3]];
	[SMSdict setValue:transitionStackValues forKey:@"BiteTransitionStack"];


	NSMutableArray *conservationsViewValues = [[NSMutableArray alloc] init];
	[conservationsViewValues addObject: @"ConversationsView"];
	[conservationsViewValues addObject: @"ComposeView"];
	[SMSdict setValue:conservationsViewValues forKey:@"BiteViewStack"];
	

	NSMutableArray *recipientValues = [[NSMutableArray alloc] init];
	[SMSdict setObject:recipientValues forKey:@"biteComposeRecipients"];
	
	[SMSdict setValue:currentText forKey:@"biteComposeText" ];
	
	plistData = [NSPropertyListSerialization dataFromPropertyList:SMSdict
										format:NSPropertyListBinaryFormat_v1_0
										errorDescription:&error];
	if(plistData)
	{
		[plistData writeToFile:@"/var/mobile/Library/Preferences/com.bitesms.plist" atomically:YES];
	}
   
	if (launchBiteSMS)
	{
		// [SuperView setTextToEdit:@"launching bitesms"];
		[ UIApp launchApplicationWithIdentifier:@"com.bitesms" suspended: NO ];
	}
	else
	{
		// [SuperView setTextToEdit:@"launching mobile sms"];
		[ UIApp launchApplicationWithIdentifier:@"com.apple.MobileSMS" suspended: NO ];
	}
}

-(void) saveTextAsNewNote
{
//	[SuperView gomerLOG];

	sqlite3 *database;
	NSTimeInterval timeStamp;
	NSString *noteText = [SuperView getCurrentHTML];
	NSString *noteSubject = [[SuperView getCurrentText] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	noteText = [noteText stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
	noteSubject = [noteSubject stringByReplacingOccurrencesOfString: @"'" withString: @"''"];
	
	NSString *path = @"/var/mobile/Library/Notes/notes.db";
	int idForNewNote;
	NSString *sqlStatement;
	
	int rangeForNoteSubject = 30;
	
	if ([noteSubject length] < 30)
		rangeForNoteSubject =  [noteSubject length];


	timeStamp = [NSDate timeIntervalSinceReferenceDate];
	
	if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) 
	{
	
		sqlStatement = [NSString stringWithFormat: 
			@"INSERT INTO Note(creation_date, title, summary, contains_cjk) VALUES( %u,'%@', '', 0)", 
			(unsigned int)timeStamp,
			[noteSubject substringWithRange:NSMakeRange(0,rangeForNoteSubject)]];
			
											
		//[SuperView setTextToEdit: sqlStatement]; sqlite3_close(database); return;
	
		//const char *sql = "SELECT * FROM note_bodies WHERE 1";
		sqlite3_stmt *statement1 ;
		sqlite3_stmt *statement2 ;
		sqlite3_stmt *statement3 ;
		
		if (sqlite3_prepare(database, [sqlStatement UTF8String], -1, &statement1, NULL) == SQLITE_OK) 
		{
			sqlite3_step(statement1);
		}
		sqlite3_finalize(statement1);
		
		sqlStatement = @"SELECT MAX(ROWID) FROM Note";
		if (sqlite3_prepare(database, [sqlStatement UTF8String], -1, &statement2, NULL) == SQLITE_OK) 
		{
			sqlite3_step(statement2);
			idForNewNote = sqlite3_column_int(statement2, 0) ;
		}
		sqlite3_finalize(statement2);
		
		// noteText = [noteText stringByReplacingOccurrencesOfString: @"<" withString: @"&lt;"];
		// noteText = [noteText stringByReplacingOccurrencesOfString: @">" withString: @"&gt;"];
		
		sqlStatement = [NSString stringWithFormat: 
			@"INSERT INTO note_bodies(note_id, data) VALUES(%d, '%@')", 
			idForNewNote, 
			noteText];
			
		if (sqlite3_prepare(database, [sqlStatement UTF8String], -1, &statement3, NULL) == SQLITE_OK) 
		{
			sqlite3_step(statement3);
		}
		sqlite3_finalize(statement3);
		
	}
	
	sqlite3_close(database);

}

-(void) prepareAndLaunchMail
{
	NSString *mailBody = [SuperView getCurrentHTML];
	
	mailBody = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) mailBody, NULL, NULL, kCFStringEncodingUTF8);
	mailBody = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) mailBody, CFSTR("%"), CFSTR("&"), kCFStringEncodingUTF8);	
	mailBody = [mailBody stringByReplacingOccurrencesOfString: @"\"" withString: @"%22"];
	mailBody = [NSString stringWithFormat:@"mailto:?body=%@%%0A", mailBody];
	
//	[SuperView setTextToEdit:mailBody];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString: mailBody]];
}

-(void) showSaveFileSheet
{
	saveSheet = [ [ UIAlertSheet alloc ] init ];
	[ saveSheet setTitle:@"Save File" ];
	[ saveSheet setBodyText:@"Please enter full path to save the file" ];
	[ saveSheet setContext:@"_saveSheet" ];
	[ saveSheet addButtonWithTitle:@"Save" ];
	[ saveSheet addButtonWithTitle:@"Cancel" ];
	[ saveSheet setDelegate: self ];
	[ saveSheet setNumberOfRows: 1 ];
	[ saveSheet addTextFieldWithValue:nil label:@"ex: /var/mobile/test.txt" ];
	[ saveSheet popupAlertAnimated: YES ];
}

-(void) showAboutSheet
{
	aboutSheet = [ [ UIAlertSheet alloc ] init ];
	[ aboutSheet setTitle:@"CopierciN (v0.3)" ];
	[ aboutSheet setBodyText:
@"by GomerciN (2008)\n\
CopierciN is a text editor which makes it possible to exchange text between messages, eMails, notes, contacts and files\n\n\
Make sure to visit http://copiercin.gomercin.net for more information\n\n\
Meanwhile, I will not stop you if you wish to donate :)" ];

	[ aboutSheet setContext:@"_aboutSheet" ];
	[ aboutSheet addButtonWithTitle:@"OK" ];
	[ aboutSheet addButtonWithTitle:@"Donate" ];
	[ aboutSheet setDelegate: self ];
	[ aboutSheet setNumberOfRows: 1 ];
	[ aboutSheet popupAlertAnimated: YES ];
}


- (void) gomLOG:(NSString *) log
{
	FILE *outfile;
	outfile = fopen("/var/mobile/Documents/gomerlog.txt", "a");
	fprintf(outfile, "\n**********\n%s", [log UTF8String]);
	fclose(outfile);
}


-(void) prepareSafariJSPasteObject
{
	system("kill -9 `ps awwx | grep MobileSafari | grep -v grep | sed -e s/\\?.*//`");
	NSString *currentText = [SuperView getCurrentText];
	
	// currentText = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) currentText, NULL, NULL, kCFStringEncodingUTF8);
	// currentText = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef) currentText, CFSTR("%"), CFSTR("&"), kCFStringEncodingUTF8);	
	currentText = [currentText stringByReplacingOccurrencesOfString: @"\\" withString: @"\\\\"];
	currentText = [currentText stringByReplacingOccurrencesOfString: @"'" withString: @"\\'"];
	currentText = [currentText stringByReplacingOccurrencesOfString: @"\"" withString: @"\\\""];
	currentText = [currentText stringByReplacingOccurrencesOfString: @"\n" withString: @"\\n"];
	   

	NSMutableDictionary *bookmarksDict = [[NSMutableDictionary alloc] init];	
	NSMutableArray *bookmarksChildren = [[NSMutableArray alloc] init];

	NSString *error;
	
	bookmarksDict = [bookmarksDict initWithContentsOfFile:@"/var/mobile/Library/Safari/Bookmarks.plist"];	
	if (!bookmarksDict)
	{
		//init a basic one
		bookmarksDict = [[NSMutableDictionary alloc] init];
		
			NSMutableDictionary *pasterDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *initerDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *pasterSubDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *initerSubDict = [[NSMutableDictionary alloc] init];
			
			NSString *JSPasteString = [NSString stringWithFormat: @"javascript:(function()%%7Bif(document.lastFocusedFrame)%%7Bif(document.lastFocusedFrame.lastFocusedObject)document.lastFocusedFrame.lastFocusedObject.value+='%@';%%7Dif(document.lastFocusedObject)document.lastFocusedObject.value+='%@';%%7D)();", currentText, currentText ];
			[pasterSubDict setObject:JSPasteString forKey:@""];
			[pasterSubDict setObject:@"CopierciN-Paste" forKey:@"title"];
			
			[pasterDict setObject:pasterSubDict forKey:@"URIDictionary"];
			[pasterDict setObject:JSPasteString forKey:@"URLString"];
			[pasterDict setObject:@"WebBookmarkTypeLeaf" forKey:@"WebBookmarkType"];
			[pasterDict setObject:@"4444444444-00C3-464B-8E55-8D16B38D5A51" forKey:@"WebBookmarkUUID"];
			
			[bookmarksChildren addObject: pasterDict];	
		
			//create init bookmarklet			
			
			NSString *JSInitString = @"javascript:(function()%7Bvar%20documentFrames=document.getElementsByTagName('frame');var%20numFrames=0;if(documentFrames)%7BnumFrames=documentFrames.length;%7Dvar%20currentDocument;for(var%20m=0;m%3C=numFrames;m++)%7Bif(m==numFrames)%7BcurrentDocument=document;%7Delse%7BcurrentDocument=documentFrames%5Bm%5D.contentDocument;documentFrames%5Bm%5D.onfocus=function()%7Bdocument.lastFocusedFrame=this%7D;%7Dvar%20inputElements=currentDocument.getElementsByTagName('input');var%20textareaElements=currentDocument.getElementsByTagName('textarea');var%20numElements;numElements=inputElements.length;for(var%20i=0;i%3CnumElements;i++)%7Bvar%20currentElement=inputElements%5Bi%5D;if((currentElement.getAttribute('type')=='text')||(currentElement.getAttribute('type')=='password'))%7BcurrentElement.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7DnumElements=textareaElements.length;for(var%20j=0;j%3CnumElements;j++)%7BtextareaElements%5Bj%5D.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7D%7D)()";
			[initerSubDict setObject:JSInitString forKey:@""];
			[initerSubDict setObject:@"CopierciN-Initialize" forKey:@"title"];
			
			[initerDict setObject:initerSubDict forKey:@"URIDictionary"];
			[initerDict setObject:JSInitString forKey:@"URLString"];
			[initerDict setObject:@"WebBookmarkTypeLeaf" forKey:@"WebBookmarkType"];
			[initerDict setObject:@"55555555-00C3-464B-8E55-8D16B38D5A51" forKey:@"WebBookmarkUUID"];
			
			[bookmarksChildren addObject: initerDict];			
				
		[bookmarksDict setObject: bookmarksChildren forKey:@"Children"];
		
			// <key>WebBookmarkFileVersion</key>
			// <integer>1</integer>
			// <key>WebBookmarkType</key>
			// <string>WebBookmarkTypeList</string>
			// <key>WebBookmarkUUID</key>
			// <string>Root</string>
			
		[bookmarksDict setObject:[NSNumber numberWithInt: 1] forKey:@"WebBookmarkFileVersion"];	
		[bookmarksDict setObject:@"WebBookmarkTypeList" forKey:@"WebBookmarkType"];	
		[bookmarksDict setObject:@"Root" forKey:@"WebBookmarkUUID"];	
		
		NSData *plistData;
		plistData = [NSPropertyListSerialization dataFromPropertyList:bookmarksDict
										format:NSPropertyListBinaryFormat_v1_0
										errorDescription:&error];
		if(plistData)
		{
			[plistData writeToFile:@"/var/mobile/Library/Safari/Bookmarks.plist" atomically:YES];
		}
		else
		{
			[self gomLOG:error];
		}
	}
	else
	{
		bookmarksChildren = [bookmarksDict objectForKey:@"Children"];
		//bookmarksChildren holds an array of dictionaries. 
		//each array object is either a bookmark or a folder

		//else if ([[SMSdict objectForKey:@"biteDefaultApp"] boolValue])
		NSEnumerator *forEach = [bookmarksChildren objectEnumerator];
		NSMutableDictionary *currentDict = [[NSMutableDictionary alloc] init];
		BOOL foundPaster = NO;
		BOOL foundInit   = NO;
				
		while (currentDict = [forEach nextObject])	
		{
			NSMutableDictionary *currentSubDict = [currentDict objectForKey:@"URIDictionary"];
			if(currentSubDict)
			{
				NSString *currentTitle = [[NSString alloc] initWithString:[currentSubDict objectForKey:@"title"]];
				if([ currentTitle isEqualToString:@"CopierciN-Paste"])
				{
					NSString *JSString = [NSString stringWithFormat: @"javascript:(function()%%7Bif(document.lastFocusedFrame)%%7Bif(document.lastFocusedFrame.lastFocusedObject)document.lastFocusedFrame.lastFocusedObject.value+='%@';%%7Dif(document.lastFocusedObject)document.lastFocusedObject.value+='%@';%%7D)();", currentText, currentText ];
					[currentDict setObject:JSString forKey:@"URLString"];
					[currentSubDict setObject:JSString forKey:@""];
					
					foundPaster = YES;
					//[self gomLOG:[currentSubDict objectForKey:@""]];
					
					//necessary?
					[currentDict setObject:currentSubDict forKey:@"URIDictionary"];
				}
				
				if([ currentTitle isEqualToString:@"CopierciN-Initialize"])
				{
					foundInit = YES;
				}
				
				if (foundPaster == YES && foundInit == YES) break; //Only first instance is modified, should it be so?				
			}
		}
		
		if (foundPaster == NO)
		{
			//create paster bookmarklet
			
			NSMutableDictionary *pasterDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *pasterSubDict = [[NSMutableDictionary alloc] init];
			
			NSString *JSString = [NSString stringWithFormat: @"javascript:(function()%%7Bif(document.lastFocusedFrame)%%7Bif(document.lastFocusedFrame.lastFocusedObject)document.lastFocusedFrame.lastFocusedObject.value+='%@';%%7Dif(document.lastFocusedObject)document.lastFocusedObject.value+='%@';%%7D)();", currentText, currentText ];
			[pasterSubDict setObject:JSString forKey:@""];
			[pasterSubDict setObject:@"CopierciN-Paste" forKey:@"title"];
			
			[pasterDict setObject:pasterSubDict forKey:@"URIDictionary"];
			[pasterDict setObject:JSString forKey:@"URLString"];
			[pasterDict setObject:@"WebBookmarkTypeLeaf" forKey:@"WebBookmarkType"];
			[pasterDict setObject:@"44444444-00C3-464B-8E55-8D16B38D5A51" forKey:@"WebBookmarkUUID"];
			
			//[bookmarksChildren addObject: pasterDict];		
			[bookmarksChildren insertObject: pasterDict atIndex: 0];		
			
			// <dict>
				// <key>URIDictionary</key>
				// <dict>
					// <key></key>
					// <string>javascript:(function()%7Bif(document.lastFocusedFrame)%7Bif(document.lastFocusedFrame.lastFocusedObject)document.lastFocusedFrame.lastFocusedObject.value+='gomercinhederoy\nsadgomer de \ngomgom heleloy asdsdsd as';%7Dif(document.lastFocusedObject)document.lastFocusedObject.value+='gomercinhederoy\nsadgomer de \ngomgom heleloy asdsdsd as';%7D)();</string>
					// <key>title</key>
					// <string>CopierciN-Paste</string>
				// </dict>
				// <key>URLString</key>
				// <string>javascript:(function()%7Bif(document.lastFocusedFrame)%7Bif(document.lastFocusedFrame.lastFocusedObject)document.lastFocusedFrame.lastFocusedObject.value+='gomercinhederoy\nsadgomer de \ngomgom heleloy asdsdsd as';%7Dif(document.lastFocusedObject)document.lastFocusedObject.value+='gomercinhederoy\nsadgomer de \ngomgom heleloy asdsdsd as';%7D)();</string>
				// <key>WebBookmarkType</key>
				// <string>WebBookmarkTypeLeaf</string>
				// <key>WebBookmarkUUID</key>
				// <string>37DC9747-00C3-464B-8E55-8D16B38D5A51</string>
			// </dict>
		}
		
		if (foundInit == NO)
		{
			//create init bookmarklet			
			NSMutableDictionary *pasterDict = [[NSMutableDictionary alloc] init];
			NSMutableDictionary *pasterSubDict = [[NSMutableDictionary alloc] init];
			
			NSString *JSString = @"javascript:(function()%7Bvar%20documentFrames=document.getElementsByTagName('frame');var%20numFrames=0;if(documentFrames)%7BnumFrames=documentFrames.length;%7Dvar%20currentDocument;for(var%20m=0;m%3C=numFrames;m++)%7Bif(m==numFrames)%7BcurrentDocument=document;%7Delse%7BcurrentDocument=documentFrames%5Bm%5D.contentDocument;documentFrames%5Bm%5D.onfocus=function()%7Bdocument.lastFocusedFrame=this%7D;%7Dvar%20inputElements=currentDocument.getElementsByTagName('input');var%20textareaElements=currentDocument.getElementsByTagName('textarea');var%20numElements;numElements=inputElements.length;for(var%20i=0;i%3CnumElements;i++)%7Bvar%20currentElement=inputElements%5Bi%5D;if((currentElement.getAttribute('type')=='text')||(currentElement.getAttribute('type')=='password'))%7BcurrentElement.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7DnumElements=textareaElements.length;for(var%20j=0;j%3CnumElements;j++)%7BtextareaElements%5Bj%5D.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7D%7D)()";
			[pasterSubDict setObject:JSString forKey:@""];
			[pasterSubDict setObject:@"CopierciN-Initialize" forKey:@"title"];
			
			[pasterDict setObject:pasterSubDict forKey:@"URIDictionary"];
			[pasterDict setObject:JSString forKey:@"URLString"];
			[pasterDict setObject:@"WebBookmarkTypeLeaf" forKey:@"WebBookmarkType"];
			[pasterDict setObject:@"55555555-00C3-464B-8E55-8D16B38D5A51" forKey:@"WebBookmarkUUID"];
			
			//[bookmarksChildren addObject: pasterDict];			
			[bookmarksChildren insertObject: pasterDict atIndex: 0];			
			// <dict>
				// <key>URIDictionary</key>
				// <dict>
					// <key></key>
					// <string>javascript:(function()%7Bvar%20documentFrames=document.getElementsByTagName('frame');var%20numFrames=0;if(documentFrames)%7BnumFrames=documentFrames.length;%7Dvar%20currentDocument;for(var%20m=0;m%3C=numFrames;m++)%7Bif(m==numFrames)%7BcurrentDocument=document;%7Delse%7BcurrentDocument=documentFrames%5Bm%5D.contentDocument;documentFrames%5Bm%5D.onfocus=function()%7Bdocument.lastFocusedFrame=this%7D;%7Dvar%20inputElements=currentDocument.getElementsByTagName('input');var%20textareaElements=currentDocument.getElementsByTagName('textarea');var%20numElements;numElements=inputElements.length;for(var%20i=0;i%3CnumElements;i++)%7Bvar%20currentElement=inputElements%5Bi%5D;if(currentElement.getAttribute('type')=='text')%7BcurrentElement.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7DnumElements=textareaElements.length;for(var%20j=0;j%3CnumElements;j++)%7BtextareaElements%5Bj%5D.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7D%7D)()</string>
					// <key>title</key>
					// <string>CopierciN-Initialize</string>
				// </dict>
				// <key>URLString</key>
				// <string>javascript:(function()%7Bvar%20documentFrames=document.getElementsByTagName('frame');var%20numFrames=0;if(documentFrames)%7BnumFrames=documentFrames.length;%7Dvar%20currentDocument;for(var%20m=0;m%3C=numFrames;m++)%7Bif(m==numFrames)%7BcurrentDocument=document;%7Delse%7BcurrentDocument=documentFrames%5Bm%5D.contentDocument;documentFrames%5Bm%5D.onfocus=function()%7Bdocument.lastFocusedFrame=this%7D;%7Dvar%20inputElements=currentDocument.getElementsByTagName('input');var%20textareaElements=currentDocument.getElementsByTagName('textarea');var%20numElements;numElements=inputElements.length;for(var%20i=0;i%3CnumElements;i++)%7Bvar%20currentElement=inputElements%5Bi%5D;if(currentElement.getAttribute('type')=='text')%7BcurrentElement.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7DnumElements=textareaElements.length;for(var%20j=0;j%3CnumElements;j++)%7BtextareaElements%5Bj%5D.onfocus=function()%7Bdocument.lastFocusedObject=this%7D;%7D%7D%7D)()</string>
				// <key>WebBookmarkType</key>
				// <string>WebBookmarkTypeLeaf</string>
				// <key>WebBookmarkUUID</key>
				// <string>55555555-00C3-464B-8E55-8D16B38D5A51</string>
			// </dict>
		}
		
		[bookmarksDict setObject: bookmarksChildren forKey:@"Children"];
		
		NSData *plistData;
		plistData = [NSPropertyListSerialization dataFromPropertyList:bookmarksDict
										format:NSPropertyListBinaryFormat_v1_0
										errorDescription:&error];
		if(plistData)
		{
			[plistData writeToFile:@"/var/mobile/Library/Safari/Bookmarks.plist" atomically:YES];
		}
		
	}
	
}

-(void)tableRowSelected:(NSNotification*)notification{

	UITable* actColum = [notification object];
	int row = [actColum selectedRow];

	switch (row)
	{
		//0: label
		case 1: [ SuperView flipTo: enumSMSView]; break;
		case 2: [ SuperView flipTo: enumContactsView] ; break;
		case 3: [ SuperView flipTo: enumNotesView] ; break;
		case 4: [ SuperView flipTo: enumMailView]; break;
		case 5: [self showLoadFileSheet]; break;
		//6: label
		case 7: [self prepareAndLaunchSMS]; break;
		case 8: [self saveTextAsNewNote]; break;
		case 9: [self prepareAndLaunchMail]; break;
		case 10: [self prepareSafariJSPasteObject];break;
		case 11: [self showSaveFileSheet]; break;
		case 13: [self showAboutSheet]; break;
	}

[[[notification object]cellAtRow:[[notification object]selectedRow]column:0] setSelected:FALSE withFade:TRUE];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if(sheet == saveSheet)
		{
			if(button == 1)
				{
					[ SuperView saveToFile: [ [ sheet textField ] text ] ];
				}
		}
	else if(sheet == loadSheet)
		{
			if(button == 1)
				{
					[ SuperView loadFile: [ [ sheet textField ] text ] ];
					[ SuperView flipTo: enumTextPage];
				}
		}
	else if (sheet == aboutSheet)
	{
		if(button == 2)
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=gomercin%40gmail%2ecom&item_name=CopierciN%20by%20GomerciN&no_shipping=0&no_note=1&tax=0&currency_code=USD&lc=TR&bn=PP%2dDonationsBF&charset=UTF%2d8"]];
		}
	}
	[ sheet dismiss ];
}

- (void)dealloc
{
    [cells release];
    [groupcell release];

    [SuperView release];
	[saveSheet release];
	[loadSheet release];
	[aboutSheet release];
	
	[ self dealloc ];
	[ super dealloc ];
}
@end
