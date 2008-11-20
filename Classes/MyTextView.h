#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UINavigationBar.h>
#import <UIKit/UINavigationItem.h>
#import <UIKit/UITransitionView.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIControl.h>
#import <UIKit/UISegmentedControl.h>
//#import <UIKit/UIKeyboard.h>
//typedef unsigned int NSUInteger;
#import <UIKit/UITouch.h>
#import <UIKit/UIEvent.h>
#import <UIKit/UIKeyboardImpl.h>
#include <UIKit/UIKeyboard.h>
#include <UIKit/UIKeyboardImpl.h>
#include <sqlite3.h>


/*
@interface UIKeyboardImpl (MyKeyboard)
- (void)markGivenSubString;
@end
*/

// @interface UITextView (GomerciN)
// -(UIWebView *) getWebView;
// @end



@interface MyTextView: UITextView
{
	int copyBegin;
	int copyEnd;

	int isClearing;
	int isSelecting;
	int wasSelecting;
	
	int markBegin;
	int markEnd;
	int markTmp;

	@private NSString* clipboard;
	
	@private NSString* magicMarkerString;
	@private NSString* copyBeginMarkerString;
	@private NSString* copyEndMarkerString;
}

- (BOOL) canBecomeFirstResponder;
- (int) GetCursorPosition;
- (int) copyBegin;
- (int) copyEnd;
- (void) clearSelection:(int)offset;

- (BOOL) canHandleGestures;
- (void) markSelection;
- (void) keyboardInputChanged:(id)fp8;
- (void) initVariables;

- (void) PasteFromClipboard;
- (void) CopyToClipboard;
- (void) CutToClipboard;

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (void) savePageToFile;
- (void) dealloc;
@end; 