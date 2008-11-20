#import "MyTextView.h"

#import <UIKit/UIWebView.h>
//#import <UIKit/UIWebView-Interaction.h>

@interface UIWebView (GomerciN)
//- (void)updateTextLoupe:(struct CGPoint)fp8;
- (void)insertText:(id)fp8;
- (void)replaceCurrentWordWithText:(id)fp8;	// IMP=0x324047bc
@end
@implementation UIWebView (GomerciN)
- (void)insertText:(id)fp8
{
//if([fp8 isEqualToString: @"a"]) fp8 = @"s";
fp8 = @"insert";
[super insertText:fp8];
}

- (void)replaceCurrentWordWithText:(id)fp8
{
//if([fp8 isEqualToString: @"<div>"]) fp8 = @"s";
fp8 = @"replace";
[super insertText:fp8];
}

@end

/*
@implementation UIKeyboardImpl (MyKeyboard)
- (void)markGivenSubString
{
//		[self addInputString: @"hobarey"];

//UIAutoCorrectInlinePrompt *m_autocorrectPrompt

		//[m_autocorrectPrompt setPosition: 12];
		[m_autocorrectPrompt setSelectedItem: 5];



}

@end

*/


// @implementation UITextView (GomerciN)

// -(WebView *) getWebView
// {
	// return m_webView;
// }
// @end

@implementation MyTextView


-(BOOL) canBecomeFirstResponder {
  return YES;
}

- (BOOL) canHandleGestures 
{
	return NO;
}
/*
-(BOOL) canResignFirstResponder {
  return YES;
}*/

- (int) GetCursorPosition
{
	NSRange currentCursorPosition = self.selectedRange; 

	return currentCursorPosition.location;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	int numTaps = [[touches anyObject] tapCount];
	if(numTaps == 1) {
		isSelecting = 0;
	}
	
	[super touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	int numTaps = [[touches anyObject] tapCount];
	
	NSString *tmp;
	
	NSRange currentRange = [self selectedRange];
	static int wasSelectingInReverse = 0;
	
	if((numTaps == 1) && (currentRange.location != copyBegin))
	{
		if (isSelecting == 0)
		{
			[self  clearSelection: 0];
			[[UIKeyboardImpl sharedInstance] addInputString:magicMarkerString];
			
			//tmp = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString:magicMarkerString withString:copyBeginMarkerString];
			
			tmp = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString:magicMarkerString withString:@"<!--GomCopyBeginned--><font style=\"background-color: #AAAAFF\"><!--GomEnded--></font>"];			
			//tmp = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString:magicMarkerString withString:@"<!--GomCopyBeginned--><b><!--GomEnded--></b>"];			
			tmp = [tmp stringByReplacingOccurrencesOfString: @"<div>" withString: @""];
			tmp = [tmp stringByReplacingOccurrencesOfString: @"</div>" withString: @"<br>"];
				tmp = [tmp stringByReplacingOccurrencesOfString:@"Â" withString: @""];
			[self setContentToHTMLString: tmp];
			
			
			copyBegin = currentRange.location;
			isSelecting = 1;
		}
		else if (isSelecting == 1)
		{
			[[UIKeyboardImpl sharedInstance] addInputString:magicMarkerString];

			tmp = [self contentAsHTMLString];
			
			if(currentRange.location >= copyBegin)
			{
				if (wasSelectingInReverse == 1)
				{
					wasSelectingInReverse = 0;
					tmp = [tmp stringByReplacingOccurrencesOfString:copyBeginMarkerString withString: @""];
					tmp = [tmp stringByReplacingOccurrencesOfString:copyEndMarkerString withString:copyBeginMarkerString];
				}
				tmp = [tmp stringByReplacingOccurrencesOfString:copyEndMarkerString withString: @""];
				tmp = [tmp stringByReplacingOccurrencesOfString:magicMarkerString withString:copyEndMarkerString];
			}
			else
			{
				if (wasSelectingInReverse == 0)
				{
					wasSelectingInReverse = 1;
					tmp = [tmp stringByReplacingOccurrencesOfString:copyEndMarkerString withString: @""];					
					tmp = [tmp stringByReplacingOccurrencesOfString:copyBeginMarkerString withString:copyEndMarkerString];
				}
				tmp = [tmp stringByReplacingOccurrencesOfString:copyBeginMarkerString withString: @""];
				tmp = [tmp stringByReplacingOccurrencesOfString:magicMarkerString withString:copyBeginMarkerString];
			}
			
			tmp = [tmp stringByReplacingOccurrencesOfString:@"Â" withString: @""];
			[self setContentToHTMLString: tmp];		
		}
	}
	
[super touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

	int numTaps = [[touches anyObject] tapCount];
	if(numTaps == 1) {

	if (isSelecting == 0)
		[self clearSelection: 0];
	else 
		wasSelecting = 1;

	isSelecting = -1;
	copyBegin = -1;
	}
	
	[super touchesEnded:touches withEvent:event];
}

-(int) copyBegin
{
	return copyBegin;
}

-(int) copyEnd
{
	return copyEnd;
}

-(void) clearSelection: (int) hed
{
	NSMutableString *tmp;
	//tmp = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString:copyEndMarkerString withString: @""];
	tmp = [self contentAsHTMLString];
	
	tmp = [tmp stringByReplacingOccurrencesOfString:@"<!--GomCopyBeginned--><font style=\"background-color: #AAAAFF\"> " withString: @" "];
	tmp = [tmp stringByReplacingOccurrencesOfString:@" <!--GomEnded--></font>" withString: @" "];
	tmp = [tmp  stringByReplacingOccurrencesOfString:copyEndMarkerString withString: @""];
	
	
	tmp = [tmp stringByReplacingOccurrencesOfString:@"<!--GomEnded-->" withString: @""];
	tmp = [tmp stringByReplacingOccurrencesOfString:copyBeginMarkerString withString: @""];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"<div>" withString: @""];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"</div>" withString: @"<br>"];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"Ê" withString: @""];
	tmp = [tmp stringByReplacingOccurrencesOfString:@"Â" withString: @""];
	

	[self setContentToHTMLString: tmp];
//	[[UIKeyboardImpl sharedInstance] addInputObject: @"<b>***GomerciN***</b>"];
copyBegin = -1; 
}

-(void) markSelection
{
	// NSString *tmp;
	// tmp = [self contentAsHTMLString];
	
		// tmp = [tmp stringByReplacingOccurrencesOfString: @"<!--GomEnded--></font>" withString: @""];
		// tmp = [tmp stringByReplacingOccurrencesOfString: @"<!--GomEnded-->" withString: @""];
		// tmp = [tmp stringByReplacingOccurrencesOfString: @"<!--GomEnd-->" withString: @"<!--GomEnded--></font>"];
				
	// [self setContentToHTMLString: tmp];				
}

-(void) initVariables
{
	copyBegin = copyEnd = markBegin = markEnd = -1;
	isClearing = 0;
	isSelecting = -1;
	
	magicMarkerString = @"***GomerciN***";
	copyBeginMarkerString = @"<!--GomCopyBeginned--><font style=\"background-color: #AAAAFF\">";
	// copyBeginMarkerString = @"<!--GomCopyBeginned--><b>";
	copyEndMarkerString = @"<!--GomEnded--></font>";
	// copyEndMarkerString = @"<!--GomEnded--></b>";
}

- (void)keyboardInputChanged:(id)fp8
{
	[super keyboardInputChanged: fp8];

	if (wasSelecting == 1)
	{
		[self clearSelection:1];
	}

	wasSelecting = 0;
}




- (void) savePageToFile
{
	// FILE *outfile;
	// outfile = fopen("/var/mobile/Documents/gomerlog.txt", "a");
	// fprintf(outfile, "\n**********\n%s", [[self contentAsHTMLString] UTF8String]);
	// fclose(outfile);
}



- (void) PasteFromClipboard
{
[self  clearSelection: 0];

	NSRange sRange = [self selectedRange];
	NSString *tmp1;
	tmp1 = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString: @"<div>" withString: @""];
	tmp1 = [tmp1 stringByReplacingOccurrencesOfString: @"</div>" withString: @"<br>"];
	[self setContentToHTMLString: tmp1];
	
		[self setSelectedRange:sRange];
		
	if (clipboard == NULL)
	{
		clipboard = @"";
	}

	// NSData *clipboardData = [[ NSFileManager defaultManager ] contentsAtPath: @"/var/mobile/Documents/clipboard.gom" ];
	// NSString * toPaste;

	// if (clipboardData != nil)
		// toPaste = [ [ NSString alloc ] initWithData: clipboardData  encoding:NSUTF8StringEncoding ];
	// else
		// toPaste = [ [ NSString alloc ] initWithString: clipboard];
		
	NSString * 	toPaste = [ [ NSString alloc ] initWithData: 
			[[ NSFileManager defaultManager ] contentsAtPath: @"/var/mobile/Documents/clipboard.gom" ]  
			encoding:NSUTF8StringEncoding ];
			
	[[UIKeyboardImpl sharedInstance] addInputString: @"***GomerciN***"];
				
	NSString *tmp;
	tmp = [[self contentAsHTMLString] stringByReplacingOccurrencesOfString: @"***GomerciN***" withString: toPaste];
	[self setContentToHTMLString: tmp];
	
	[self setSelectedRange:sRange];
}

- (void) CopyToClipboard
{
 	clipboard = [self contentAsHTMLString];
	
	NSRange rangeBegin = [clipboard rangeOfString: copyBeginMarkerString];
	NSRange rangeEnd   = [clipboard rangeOfString: copyEndMarkerString];
	
	if ((rangeBegin.location == NSNotFound) || (rangeEnd.location == NSNotFound)) 
	return;
	
	NSRange range = {rangeBegin.location+rangeBegin.length, rangeEnd.location - rangeBegin.location - rangeBegin.length};
	clipboard = [clipboard substringWithRange: range];
	clipboard = [clipboard stringByReplacingOccurrencesOfString:@"Â" withString: @""];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath: @"/var/mobile/Documents" attributes: nil];
	
	[clipboard 
	   writeToFile: @"/var/mobile/Documents/clipboard.gom"
	   atomically: NO 
	   encoding: NSUTF8StringEncoding
	   error: nil]; 
}

- (void) CutToClipboard
{
	clipboard = [self contentAsHTMLString];
	
	NSRange rangeBegin = [clipboard rangeOfString: copyBeginMarkerString];
	NSRange rangeEnd   = [clipboard rangeOfString: copyEndMarkerString];
	
	if ((rangeBegin.location == NSNotFound) || (rangeEnd.location == NSNotFound)) 
	return;
	
	NSRange range = {rangeBegin.location+rangeBegin.length, rangeEnd.location - rangeBegin.location - rangeBegin.length};
	clipboard = [clipboard substringWithRange: range];
	
	NSFileManager *fm = [NSFileManager defaultManager];
	[fm createDirectoryAtPath: @"/var/mobile/Documents" attributes: nil];
	
	[clipboard 
	   writeToFile: @"/var/mobile/Documents/clipboard.gom"
	   atomically: NO 
	   encoding: NSUTF8StringEncoding
	   error: nil];

	NSRange range2 = {rangeBegin.location, rangeEnd.location-rangeBegin.location+rangeEnd.length};
	clipboard = [[self contentAsHTMLString] stringByReplacingCharactersInRange:range2 withString:@""];
	[self setContentToHTMLString: clipboard];
}

- (void)dealloc
{
	[clipboard release];
	
	[magicMarkerString release];
	[copyBeginMarkerString release];
	[copyEndMarkerString release];
	
	[ self dealloc ];
	[ super dealloc ];
}

// - (BOOL)webView:(id)fp8 shouldDeleteDOMRange:(id)fp12
// {
	// return NO;
// }
// - (BOOL)webView:(id)fp8 shouldInsertText:(id)fp12 replacingDOMRange:(id)fp16 givenAction:(int)fp20
// {
	// return NO;
// }

@end
