//
//  CTConsoleController.h
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/15/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#define CT_DISPLAY_HEX        0
#define CT_DISPLAY_PLAIN_TEXT 1

#import <Foundation/Foundation.h>

@interface CTConsoleController : NSObject {
  IBOutlet NSTextView               *consoleTextView;
  IBOutlet NSUserDefaultsController *userDefaultsController;

  NSMutableAttributedString *outputTextStorage;        // a pointer to ouputTexView's textStorage

}

@property (readwrite) NSInteger displayHexOrPlainText;
@property (copy)      NSColor   *consoleErrorTextColor;
@property (copy)      NSColor   *consoleInformationTextColor;
@property (copy)      NSColor   *consoleDataTextColor;
@property (copy)      NSColor   *consoleBackgroundColor;



- (void) printString: (NSString *) theString;
- (void) printData: (unsigned char *) theData length: (int) theLength;
- (void) printHexFromData: (unsigned char *) theData length: (int) theLength;
- (void) printPlainTextFromData: (unsigned char *) theData length: (int) theLength;
- (IBAction) clearConsole: (id) sender;


@end
