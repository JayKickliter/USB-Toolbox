//
//  CTConsoleController.m
//  USB Toolbox
//
//  Created by Jay Kickliter on 10/15/12.
//  Copyright (c) 2012 Jay Kickliter. All rights reserved.
//

#import "CTConsoleController.h"

#pragma mark Defaults Keys
NSString * const CTDefault_ConsoleBackgroundColor_Key       = @"consoleBackgroundColor";
NSString * const CTDefault_ConsoleErrorTextColor_Key        = @"consoleErrorTextColor";
NSString * const CTDefault_ConsoleDataTextColor_Key         = @"consoleDataTextColor";
NSString * const CTDefault_ConsoleInformationTextColor_Key  = @"consoleInformationTextColor";
NSString * const CTDefault_DisplayHexOrPlainText_Key        = @"displayHexOrPlainText";


@implementation CTConsoleController

@synthesize displayHexOrPlainText;
@synthesize consoleErrorTextColor;
@synthesize consoleInformationTextColor;
@synthesize consoleDataTextColor;
@synthesize consoleBackgroundColor;




+ (void) initialize
{
  NSDictionary *defaultValues = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSArchiver archivedDataWithRootObject: [ NSColor blackColor ]], CTDefault_ConsoleBackgroundColor_Key,
                                    [NSArchiver archivedDataWithRootObject: [ NSColor redColor   ]], CTDefault_ConsoleErrorTextColor_Key,
                                    [NSArchiver archivedDataWithRootObject: [ NSColor greenColor ]], CTDefault_ConsoleDataTextColor_Key,
                                    [NSArchiver archivedDataWithRootObject: [ NSColor grayColor  ]], CTDefault_ConsoleInformationTextColor_Key,
                                    @"0",    CTDefault_DisplayHexOrPlainText_Key,
                                    nil ];

  [[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  outputTextStorage = [ consoleTextView textStorage ];

  [ self setupBindings ];
}



- (void) setupBindings
{
  [ consoleTextView bind: @"backgroundColor"
                toObject: userDefaultsController
             withKeyPath: [ NSString stringWithFormat: @"values.%@", CTDefault_ConsoleBackgroundColor_Key ]
                 options: [NSDictionary dictionaryWithObject: NSUnarchiveFromDataTransformerName
                                                      forKey: NSValueTransformerNameBindingOption ] ];
}



#pragma mark Printing Methods

- (void) printString: (NSString *) theString
{
  [self printString: theString withTextColor: nil ];
}



- (void) printString: (NSString *) theString withTextColor: (NSColor *) theColor
{
  NSColor *textColor;
  if ( theColor == nil ) {
    textColor = self.consoleDataTextColor;
  } else {
    textColor = theColor;
  }
  NSFont *font = [NSFont fontWithName:@"Monaco" size:13.0];
  NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, textColor, NSForegroundColorAttributeName, nil];
  NSAttributedString *attrString =  [[NSAttributedString alloc] initWithString: [NSString stringWithFormat:@"%@", theString]
                                                                    attributes:attrsDictionary];
  [ outputTextStorage appendAttributedString: attrString ];
  NSRange range;
  range = NSMakeRange ([outputTextStorage length], 0);

  [consoleTextView scrollRangeToVisible: range];
}



- (void) printData: (unsigned char *) theData length: (int) theLength
{
  switch ( displayHexOrPlainText ) {
    case CT_DISPLAY_HEX:
      [ self printHexFromData: theData length: theLength ];
      break;

    case CT_DISPLAY_PLAIN_TEXT:
      [ self printPlainTextFromData: theData length: theLength ];
      break;

    default:
      break;
  }
}



- (void) printHexFromData: (unsigned char *) theData length: (int) theLength
{
  UInt16  i;
  UInt16 address = 0;

  for (i=0; i<theLength; i++) {
    switch ( i & 0x000F ) {

      case 0x0000:
        [ self printString: [ NSString stringWithFormat: @"%04X: %02X",  address, theData[i] ]];
        break;

      case 0x000F:
        [ self printString: [ NSString stringWithFormat: @" %02X    %@\n", theData[i], [ self plainTextStringFromData: &theData[i-15] length: 16 breakNewLines: FALSE ] ]];
        address += 0x10;
        break;

      default:
        [ self printString: [ NSString stringWithFormat: @" %02X", theData[i] ]];
        break;

    }
  }
  [ self printNewLine: 2 ];
}



- (NSString *) plainTextStringFromData: (unsigned char *) theData length: (int) theLength breakNewLines: (BOOL) doNewLines
{
  int i;
  char theCString[theLength];
  NSString   *theReturnedString;

  for ( i = 0 ; i < theLength ; i++ ) {
    if ( theData[i] < 0x7F && theData[i] > 0x1F ) { // is the byte a a visible ascii character?
      theCString[i] = theData[i];
    } else if ( theData[i] == '\r' && doNewLines == TRUE ) {
      theCString[i] = theData[i];
    } else {
      theCString[i] = '.';
    }
  }
  theCString[theLength] = 0;

  theReturnedString = [ NSString stringWithCString: theCString encoding: NSASCIIStringEncoding ];

  return theReturnedString;

}



- (void) printPlainTextFromData: (unsigned char *) theData length: (int) theLength
{
  NSString *theOuputString = [ self plainTextStringFromData: theData
                                                     length: theLength
                                              breakNewLines: TRUE ];
  [ self printString: theOuputString ];
  [ self printNewLine: 2 ];
}



- (void) printNewLine: (int) numberOfNewLines
{
  int i = numberOfNewLines > 0 ? numberOfNewLines : 1;
  for ( i = 0 ; i < numberOfNewLines; i++ ) {
    [[ outputTextStorage mutableString ] appendString: @"\n" ];
  }

}



- (IBAction) clearConsole: (id) sender
{
  [[ outputTextStorage mutableString ] setString: @"" ];
}


@end
